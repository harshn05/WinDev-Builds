#!/usr/bin/env bash

# ============================================================
# WinDev - MSYS2 Custom Profile
# ============================================================
# Loaded by MSYS2 /etc/profile.
# Keep writable runtime files outside read-only ISO images.
# WINDEV, WINDEV_BASE and WINDEVTEMP are supplied by WinDev.
# ============================================================

# ------------------------------------------------------------
# CMake build helpers
# ------------------------------------------------------------

build_msys2_gcc()
{
    cmake -S . -B build_msys2_gcc \
        -G "CodeBlocks - Ninja" \
		-DCMAKE_COLOR_DIAGNOSTICS=ON \
        -DCMAKE_BUILD_TYPE=Release \
        "$@" 2>&1 | tr -d '\r'

    local status="${PIPESTATUS[0]}"
    return "$status"
}

build_msys2_clang()
{
    CC=clang CXX=clang++ \
    cmake -S . -B build_msys2_clang \
        -G "CodeBlocks - Ninja" \
		-DCMAKE_COLOR_DIAGNOSTICS=ON \
        -DCMAKE_BUILD_TYPE=Release \
        "$@" 2>&1 | tr -d '\r'

    local status="${PIPESTATUS[0]}"
    return "$status"
}


# ------------------------------------------------------------
# Writable runtime directories
# ------------------------------------------------------------

if [[ -n "${WINDEVTEMP:-}" ]]; then
    if command -v cygpath >/dev/null 2>&1; then
        WINDEVTMP="$(cygpath -u "$WINDEVTEMP")"

        if mkdir -p "$WINDEVTMP/msys2tmp"; then
            export WINDEVTMP
            export TMPDIR="$WINDEVTMP/msys2tmp"
            export TMP="$WINDEVTMP/msys2tmp"
            export TEMP
            TEMP="$(cygpath -w "$WINDEVTMP/msys2tmp")"
        else
            echo "[WinDev] WARNING: Could not create $WINDEVTMP/msys2tmp" >&2
        fi
    else
        echo "[WinDev] WARNING: cygpath is unavailable; temp paths not configured." >&2
    fi
else
    echo "[WinDev] WARNING: WINDEVTEMP is not defined." >&2
fi


# ------------------------------------------------------------
# Initial working directory
# Only change directory for interactive shells.
# ------------------------------------------------------------

if [[ $- == *i* && -n "${USERPROFILE:-}" ]] &&
   command -v cygpath >/dev/null 2>&1; then
    windev_desktop="$(cygpath -u "$USERPROFILE")/Desktop"

    if [[ -d "$windev_desktop" ]]; then
        cd "$windev_desktop" ||
            echo "[WinDev] WARNING: Could not enter Desktop." >&2
    fi

    unset windev_desktop
fi


# ------------------------------------------------------------
# Load WinPython
# Usage: loadenv_WinPython
# ------------------------------------------------------------

loadenv_WinPython()
{
    local windev_root python_dir python_iso python_root helper
    local resolved_python locate_status python_lib python_version python_exe

    if [[ -z "${WINDEV:-}" ]]; then
        echo "ERROR: WINDEV is not defined." >&2
        return 1
    fi

    if ! command -v cygpath >/dev/null 2>&1; then
        echo "ERROR: cygpath is unavailable." >&2
        return 1
    fi

    windev_root="$(cygpath -u "$WINDEV")" || return 1
    windev_root="${windev_root%/}"

    python_dir="$windev_root/WinDev-Python"
    python_iso="$windev_root/WinDev-Python.iso"
    helper="$WINDEV/WinDev.cmd"

    if [[ ! -f "$helper" ]]; then
        echo "ERROR: WinDev.cmd not found: $helper" >&2
        return 1
    fi

    echo "[WinDev] Looking for Python environment..."

    resolved_python="$(
        MSYS_NO_PATHCONV=1 cmd.exe /d /c call "$helper" \
            LocateEnvironment \
            "$(cygpath -w "$python_dir")" \
            "$(cygpath -w "$python_iso")" \
            "WinDev-Python"
    )"
    locate_status=$?

    if (( locate_status != 0 )); then
        echo "ERROR: Could not locate WinDev Python environment." >&2
        return 1
    fi

    # Trim whitespace/blank lines around LocateEnvironment output.
    resolved_python="${resolved_python#"${resolved_python%%[!$' \t\r\n']*}"}"
    resolved_python="${resolved_python%"${resolved_python##*[!$' \t\r\n']}"}"

    if [[ -z "$resolved_python" ]]; then
        echo "ERROR: Python environment path is empty." >&2
        return 1
    fi

    python_root="$(cygpath -u "$resolved_python")" || return 1
    python_root="${python_root%/}"
    python_exe="$python_root/python/python.exe"

    if [[ ! -f "$python_exe" ]]; then
        echo "ERROR: Python executable not found: $python_exe" >&2
        return 1
    fi

    if [[ ! -d "$python_root/python/libs" ]]; then
        echo "ERROR: Python libs directory not found: $python_root/python/libs" >&2
        return 1
    fi

    # Detect python312.lib, python314.lib, etc., rather than hardcoding.
    python_lib="$(
        find "$python_root/python/libs" -maxdepth 1 -type f \
            -iname 'python3*.lib' -print -quit
    )"

    if [[ -z "$python_lib" ]]; then
        echo "ERROR: Python import library (python3*.lib) not found in:" >&2
        echo "       $python_root/python/libs" >&2
        return 1
    fi

    python_version="${python_lib##*/}"
    python_version="${python_version#python}"
    python_version="${python_version%.lib}"
    python_version="${python_version,,}"

    export WINDEV_PYTHON="$python_root"
    export PYTHONHOME="$python_root/python"
    export PYTHON_INCLUDE_DIR="$PYTHONHOME/include"
    export PYTHON_LIBRARY="$python_lib"
    export PYTHON_PATH="$PYTHONHOME"
    export PYTHON_LIB="$PYTHONHOME/libs"
    export PYTHON_VERSION="$python_version"

    # Windows-native build tools expect semicolon-separated paths.
    export INCLUDE="$PYTHONHOME/include${INCLUDE:+;$INCLUDE}"
    export LIB="$PYTHONHOME/libs${LIB:+;$LIB}"

    case ":$PATH:" in
        *":$PYTHONHOME:"*) ;;
        *) PATH="$PYTHONHOME:$PATH" ;;
    esac

    case ":$PATH:" in
        *":$PYTHONHOME/Scripts:"*) ;;
        *) PATH="$PYTHONHOME/Scripts:$PATH" ;;
    esac
    export PATH

    echo
    echo "[WinDev] Python environment: $WINDEV_PYTHON"
    echo "[WinDev] Python executable:  $python_exe"
    echo "[WinDev] Python library:     $PYTHON_LIBRARY"
    echo "[WinDev] Python version tag: $PYTHON_VERSION"
    echo

    if ! "$python_exe" --version; then
        echo "ERROR: Python verification failed." >&2
        return 1
    fi

    echo
    echo "[WinDev] Python environment loaded."
    echo
}


# ------------------------------------------------------------
# UCRT64 C++ include paths
# For VS Code IntelliSense, prefer CMake compile_commands.json.
# ------------------------------------------------------------

if [[ "${MSYSTEM:-}" == "UCRT64" ]]; then
    export CPLUS_INCLUDE_PATH="/ucrt64/include/ITK:/ucrt64/include/vtk:/ucrt64/include/openblas${CPLUS_INCLUDE_PATH:+:$CPLUS_INCLUDE_PATH}"
fi


# ==========================================
# COMPILER COLORS & DIAGNOSTICS (GCC / Clang)
# ==========================================
# Interactive shells only
[[ $- == *i* ]] || return

# ---------- GCC diagnostics ----------
export GCC_COLORS='error=01;31:warning=01;33:note=01;36:caret=01;32:locus=01;35:quote=01;33:fnname=01;32:targs=01;36:range1=32:range2=34:fixit-insert=32:fixit-delete=31:diff-filename=01:diff-hunk=32:diff-delete=31:diff-insert=32:type-diff=01;32'

# ---------- CMake diagnostics ----------
export CMAKE_COLOR_DIAGNOSTICS=ON

# ---------- Filesystem colors ----------
if command -v dircolors >/dev/null 2>&1; then
    if [[ -r ~/.dircolors ]]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
fi

alias ls='ls --color=auto'
alias ll='ls -lAh --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

# Enable color for iproute2, if available
if command -v ip >/dev/null 2>&1; then
    alias ip='ip -color=auto'
fi

# ---------- Pager / man page colors ----------
export LESS='-R -F -X'
export LESS_TERMCAP_md=$'\e[01;36m'
export LESS_TERMCAP_us=$'\e[04;32m'
export LESS_TERMCAP_so=$'\e[01;44;33m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'



# ------------------------------------------------------------
# Oh My Posh
# Usage: load_OhMyPosh
# Call from interactive Bash startup after PATH is configured.
# ------------------------------------------------------------

load_OhMyPosh()
{
    [[ $- == *i* ]] || return 0

    if ! command -v oh-my-posh >/dev/null 2>&1; then
        echo "[WinDev] WARNING: oh-my-posh not found in PATH." >&2
        return 1
    fi

    if [[ -z "${WINDEV_BASE:-}" ]]; then
        echo "[WinDev] WARNING: WINDEV_BASE is not defined." >&2
        return 1
    fi

    if ! command -v cygpath >/dev/null 2>&1; then
        echo "[WinDev] WARNING: cygpath is unavailable." >&2
        return 1
    fi

    local windev_base_path theme_file
    windev_base_path="$(cygpath -u "$WINDEV_BASE")" || return 1
    theme_file="$windev_base_path/_OhMyPosh/_themes/peru.omp.json"

    if [[ ! -f "$theme_file" ]]; then
        echo "[WinDev] WARNING: Oh My Posh theme not found:" >&2
        echo "          $theme_file" >&2
        return 1
    fi

    eval "$(oh-my-posh init bash --config "$theme_file")"
}


# ------------------------------------------------------------
# Export functions to child Bash processes
# ------------------------------------------------------------

export -f build_msys2_gcc
export -f build_msys2_clang
export -f loadenv_WinPython
export -f load_OhMyPosh



# ============================================================
# Initialize Oh My Posh for interactive Bash shells
# ============================================================

if [[ $- == *i* ]]; then
    load_OhMyPosh
fi



# ============================================================
# Preserve WinPython priority in login shells
# ============================================================

if [[ -n "${WINDEV_PYTHON:-}" &&
      -n "${PYTHONHOME:-}" &&
      -f "$PYTHONHOME/python.exe" ]]; then

    case "$PATH" in
        "$PYTHONHOME":*) ;;
        *)
            export PATH="$PYTHONHOME:$PYTHONHOME/Scripts:$PATH"
            ;;
    esac
fi


# End of WinDev MSYS2 custom profile
