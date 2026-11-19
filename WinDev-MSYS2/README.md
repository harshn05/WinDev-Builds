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
