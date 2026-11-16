#!/usr/bin/env bash

# ============================================================
# Copy required MSYS2 runtime/tools to current directory
# ============================================================

MSYS_BIN="/usr/bin"
UCRT_BIN="/ucrt64/bin"

# MSYS2 ecosystem files
MSYS_FILES=(
    axel.exe
    cygpath.exe
    ldd.exe
	strace.exe
    tree.exe
    msys-2.0.dll
    msys-crypto-4.dll	
    msys-ssl-4.dll    
)

# UCRT64 ecosystem files
UCRT_FILES=(
    upx.exe
	ntldd.exe
	libstdc++-6.dll
	libwinpthread-1.dll
	libgcc_s_seh-1.dll
)

echo "Copying MSYS2 files..."

for f in "${MSYS_FILES[@]}"; do
    if [[ -f "$MSYS_BIN/$f" ]]; then
        cp -v "$MSYS_BIN/$f" .
    else
        echo "WARNING: Not found: $MSYS_BIN/$f"
    fi
done

echo
echo "Copying UCRT64 files..."

for f in "${UCRT_FILES[@]}"; do
    if [[ -f "$UCRT_BIN/$f" ]]; then
        cp -v "$UCRT_BIN/$f" .
    else
        echo "WARNING: Not found: $UCRT_BIN/$f"
    fi
done

echo
echo "Done."