
#!/usr/bin/env bash

set -u

# ============================================================
# MSYS2 Package Locator
# Finds which repository packages provide selected files.
# No packages are installed.
# ============================================================

FILES=(
    axel.exe
    cygpath.exe
    ldd.exe
    strace.exe
    tree.exe
    msys-2.0.dll
    msys-crypto-4.dll
    msys-ssl-4.dll
    upx.exe
    ntldd.exe
    libstdc++-6.dll
    libwinpthread-1.dll
    libgcc_s_seh-1.dll
)

OUTPUT="msys2-package-ownership.txt"

if ! command -v pacman >/dev/null 2>&1; then
    echo "ERROR: pacman not found. Run this inside an MSYS2 terminal."
    exit 1
fi

echo
echo "============================================================"
echo " Updating MSYS2 repository file databases"
echo "============================================================"
echo

if ! pacman -Fy; then
    echo "ERROR: Failed to update repository file databases."
    exit 1
fi

echo
echo "============================================================"
echo " Searching package ownership"
echo "============================================================"

{
    echo "MSYS2 PACKAGE OWNERSHIP REPORT"
    echo "Generated: $(date)"
    echo

    for file in "${FILES[@]}"; do
        echo "------------------------------------------------------------"
        echo "FILE: $file"
        echo "------------------------------------------------------------"

        pacman -F -- "$file" 2>&1 || true
        echo
    done
} | tee "$OUTPUT"

echo
echo "============================================================"
echo " Searching locally installed ownership"
echo "============================================================"

{
    echo
    echo "INSTALLED PACKAGE OWNERSHIP"
    echo

    for file in "${FILES[@]}"; do
        echo "FILE: $file"

        # Search both MSYS and UCRT64 binary directories.
        for path in \
            "/usr/bin/$file" \
            "/ucrt64/bin/$file"; do

            if [[ -f "$path" ]]; then
                pacman -Qo "$path" 2>&1 || true
            fi
        done
        echo
    done
} | tee -a "$OUTPUT"

echo
echo "============================================================"
echo " Complete!"
echo " Report: $OUTPUT"
echo "============================================================"
