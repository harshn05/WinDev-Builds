#!/usr/bin/env bash
# WinDev portable MSYS2 / UCRT64 executable and DLL collector
# ============================================================
# Collects:
#   - MSYS2 executables from /usr/bin
#   - UCRT64 tools from /ucrt64/bin
#   - Recursive DLL dependencies using ntldd
#
# Windows system DLLs are ignored.
# ============================================================


set -uo pipefail

DEST="$(pwd -P)"
MSYS_BIN=/usr/bin
UCRT_BIN=/ucrt64/bin
NTLDD="$UCRT_BIN/ntldd.exe"
TOOLS=(axel.exe cygpath.exe ldd.exe strace.exe tree.exe)
UCRT_TOOLS=(upx.exe ntldd.exe)

COPIED_EXE=0
COPIED_DLL=0
MISSING_EXE=0
MISSING_DLL=0
SCAN_WARNINGS=0

declare -A seen_dll=() missing_dll=() scanned=()
declare -a missing_exes=() scan_queue=()

log() { printf '%s\n' "$*"; }

is_windows_system_dll() {
    local dll="${1,,}"
    case "$dll" in
        api-ms-win-*.dll|ext-ms-win-*.dll|ntdll.dll|kernel32.dll|kernelbase.dll|advapi32.dll|user32.dll|userenv.dll|profapi.dll|gdi32.dll|gdi32full.dll|shell32.dll|shlwapi.dll|ole32.dll|oleaut32.dll|combase.dll|msvcrt.dll|ucrtbase.dll|rpcrt4.dll|secur32.dll|crypt32.dll|bcrypt.dll|bcryptprimitives.dll|ws2_32.dll|wsock32.dll|winhttp.dll|wininet.dll|version.dll|imm32.dll|comdlg32.dll|setupapi.dll|cfgmgr32.dll|oleacc.dll|psapi.dll|comctl32.dll|dwmapi.dll|dnsapi.dll|iphlpapi.dll|wldap32.dll|normaliz.dll|netapi32.dll|winmm.dll|dbghelp.dll|powrprof.dll|ncrypt.dll|cryptbase.dll|mswsock.dll|wtsapi32.dll|user32.dll|shcore.dll|uxtheme.dll|ntmarta.dll|sspicli.dll|clbcatq.dll|propsys.dll|windowscodecs.dll)
            return 0 ;;
        *) return 1 ;;
    esac
}

# Prefer the directory matching the dependency's parent binary.
find_msys_dll() {
    local requested="${1,,}" origin="$2" dir candidate base
    local -a dirs
    if [[ "$origin" == "$MSYS_BIN"/* ]] || [[ "${origin,,}" == *msys-*.dll ]]; then
        dirs=("$MSYS_BIN" "$UCRT_BIN")
    else
        dirs=("$UCRT_BIN" "$MSYS_BIN")
    fi
    for dir in "${dirs[@]}"; do
        for candidate in "$dir"/*.dll "$dir"/*.DLL; do
            [[ -f "$candidate" ]] || continue
            base="${candidate##*/}"
            if [[ "${base,,}" == "$requested" ]]; then
                printf '%s\n' "$candidate"
                return 0
            fi
        done
    done
    return 1
}

# ntldd normally prints 'name.dll => path' or 'name.dll (address)'.
# Extract full names, including the '+' in libstdc++-6.dll.
extract_dll_names() {
    local file="$1" output rc
    output="$("$NTLDD" "$file" 2>&1)" || {
        rc=$?
        log "  [SCAN WARNING] ntldd returned $rc for ${file##*/}" >&2
        log "  $output" >&2
        return 1
    }
    printf '%s\n' "$output" |
        grep -Eio '[-A-Za-z0-9_+.]+\.dll' |
        tr '[:upper:]' '[:lower:]' |
        sort -u || true
}

queue_file() {
    local file="$1"
    [[ -f "$file" ]] && scan_queue+=("$file")
}

copy_exe() {
    local src="$1" name="${1##*/}" dest="$DEST/${1##*/}"
    if [[ ! -f "$src" ]]; then
        log "  [EXE MISSING] $name"
        ((MISSING_EXE+=1))
        missing_exes+=("$name")
        return
    fi
    if [[ ! -f "$dest" ]]; then
        if cp -f -- "$src" "$dest"; then
            log "  [EXE] $name"
            ((COPIED_EXE+=1))
        else
            log "  [COPY ERROR] $name"
            ((MISSING_EXE+=1))
            missing_exes+=("$name (copy failed)")
            return
        fi
    else
        log "  [EXE EXISTS] $name"
    fi
    queue_file "$src"
}

copy_dll() {
    local dll="${1,,}" origin="$2" src name dest
    [[ -n "$dll" ]] || return
    is_windows_system_dll "$dll" && return
    [[ -n "${seen_dll[$dll]:-}" ]] && return
    seen_dll[$dll]=1

    src="$(find_msys_dll "$dll" "$origin")" || {
        log "  [DLL MISSING] $dll (required by ${origin##*/})"
        missing_dll[$dll]=1
        ((MISSING_DLL+=1))
        return
    }
    name="${src##*/}"
    dest="$DEST/$name"
    if [[ ! -f "$dest" ]]; then
        if cp -f -- "$src" "$dest"; then
            log "  [DLL] $name"
            ((COPIED_DLL+=1))
        else
            log "  [COPY ERROR] $name"
            missing_dll[$dll]=1
            ((MISSING_DLL+=1))
            return
        fi
    fi
    queue_file "$src"
}

if [[ ! -f "$NTLDD" ]]; then
    log "ERROR: ntldd.exe not found: $NTLDD"
    log 'Install the MSYS2 UCRT64 ntldd package before running this script.'
    exit 1
fi

log '============================================================'
log ' Collecting MSYS2 tools'
log '============================================================'
for exe in "${TOOLS[@]}"; do copy_exe "$MSYS_BIN/$exe"; done

log '============================================================'
log ' Collecting UCRT64 tools'
log '============================================================'
for exe in "${UCRT_TOOLS[@]}"; do copy_exe "$UCRT_BIN/$exe"; done

# Also inspect previously collected executables, not just newly copied ones.
for exe in "$DEST"/*.exe; do
    [[ -f "$exe" ]] || continue
    [[ "${exe##*/}" == ntldd.exe ]] && continue
    queue_file "$exe"
done

log '============================================================'
log ' Recursive dependency scan'
log '============================================================'
index=0
while (( index < ${#scan_queue[@]} )); do
    file="${scan_queue[index]}"
    ((index+=1))
    [[ -f "$file" ]] || continue
    # Canonical path is sufficient for avoiding repeated scans in this run.
    [[ -n "${scanned[$file]:-}" ]] && continue
    scanned[$file]=1
    [[ "${file##*/}" == ntldd.exe ]] && continue
    log "Scanning: ${file##*/}"
    deps="$(extract_dll_names "$file")" || {
        ((SCAN_WARNINGS+=1))
        continue
    }
    while IFS= read -r dll; do
        [[ -n "$dll" ]] && copy_dll "$dll" "$file"
    done <<< "$deps"
done

log ''
log '============================================================'
log ' SUMMARY'
log '============================================================'
printf 'EXE copied    : %d\n' "$COPIED_EXE"
printf 'EXE missing   : %d\n' "$MISSING_EXE"
printf 'DLL copied    : %d\n' "$COPIED_DLL"
printf 'DLL missing   : %d\n' "$MISSING_DLL"
printf 'Scan warnings : %d\n' "$SCAN_WARNINGS"
log ''
log 'MISSING EXE FILES:'
if (( ${#missing_exes[@]} )); then printf '  %s\n' "${missing_exes[@]}"; else log '  None'; fi
log 'MISSING DLL FILES:'
if (( ${#missing_dll[@]} )); then printf '  %s\n' "${!missing_dll[@]}" | sort -f; else log '  None'; fi
log ''
log 'BUNDLE CONTENTS:'
find "$DEST" -maxdepth 1 -type f \( -iname '*.exe' -o -iname '*.dll' \) -printf '%f\n' | sort -f
log ''
log 'Done.'
if (( MISSING_EXE || MISSING_DLL || SCAN_WARNINGS )); then exit 1; fi
