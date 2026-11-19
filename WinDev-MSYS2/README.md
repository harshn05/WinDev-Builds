1. Install msys2 here
2. Add the following content to /etc/profile

```bash

# ============================================================
# WinDev - Load MSYS2 Custom Profile
# ============================================================
#
# Load WinDev-specific shell configuration from WinDev-Base.
#
# Profile location:
#   WinDev-Base/ConEmu/_Toolchains/msys2-profile.sh
#
# WINDEV_BASE is expected to be initialized by the WinDev
# launcher before this section executes.
#
# The profile can reside in either:
#   1. A writable WinDev-Base directory during development.
#   2. A mounted WinDev-Base ISO during distribution.
#
# ============================================================

if [[ -n "$WINDEV_BASE" ]]; then

    # Convert the resolved Base path to MSYS2 path format.
    windev_base_path="$(cygpath -u "$WINDEV_BASE")"

    # Construct the path to the custom MSYS2 profile.
    windev_profile="$windev_base_path/_Toolchains/msys2-profile.sh"

    # Load the custom profile if it exists.
    if [[ -f "$windev_profile" ]]; then

        source "$windev_profile"

    else

        echo "[WinDev] WARNING: MSYS2 profile not found:" >&2
        echo "          $windev_profile" >&2

    fi

    # Clean up temporary variables.
    unset windev_base_path
    unset windev_profile

else

    echo "[WinDev] WARNING: WINDEV_BASE is not defined." >&2
    echo "          Custom MSYS2 profile was not loaded." >&2

fi

# ============================================================
# End of WinDev Custom Profile Loader
# ============================================================
```
3. Update pacman -Syu (do it 2-3 times)
4. Install these packages

```bash
pacman -S axel make tree bc bison diffutils dos2unix flex m4 patch sharutils zip unrar mingw-w64-ucrt-x86_64-{vtk,itk,muparser,armadillo,cmake-gui,gcc,gcc-fortran,qt6,cli11,openvr,anari-sdk,boost,seacas,adios2,gl2ps,proj,openslide,eigen3,utf8cpp,exprtk,nlohmann-json,gtest,wxwidgets3.2,git-gui,graphviz,doxygen,ntldd,opencv,upx,octave,codeblocks,toolchain,qt-creator,indent,putty,clang,clang-tools-extra,llvm-openmp}
```
5. REMOVE LARGE and UNNECESSARY PACKAGES:
```bash
pacman -R mingw-w64-ucrt-x86_64-qt6-doc
```
6. clear pacman cache located in /var/cache/pacman/pkg/
7. This directory roughly looks like:

.
├── autorebase.bat
├── bin
├── clang64
├── clang64.exe
├── clang64.ico
├── clang64.ini
├── clangarm64
├── clangarm64.exe
├── clangarm64.ico
├── clangarm64.ini
├── components.xml
├── dev
├── etc
├── home
├── InstallationLog.txt
├── installer.dat
├── installerResources
├── mingw32
├── mingw32.exe
├── mingw32.ico
├── mingw32.ini
├── mingw64
├── mingw64.exe
├── mingw64.ico
├── mingw64.ini
├── msys2.exe
├── msys2.ico
├── msys2.ini
├── msys2_shell.cmd
├── network.xml
├── opt
├── proc
├── tmp
├── ucrt64
├── ucrt64.exe
├── ucrt64.ico
├── ucrt64.ini
├── uninstall.dat
├── uninstall.exe
├── uninstall.ini
├── usr
└── var

16 directories, 27 files




