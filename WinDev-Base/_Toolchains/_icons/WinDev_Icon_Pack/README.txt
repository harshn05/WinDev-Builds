WinDev Icon Pack
===============

WinDev.ico: Multi-resolution Windows icon containing 16, 24, 32, 48, 64, 128 and 256 px sizes.
WinDev_Master.png: 1024x1024 master image.
WinDev_<size>x<size>.png: Individual PNG exports.

To embed the icon in the C++ executable, place WinDev.ico beside WinDev.rc and use:
IDI_APP_ICON ICON "WinDev.ico"

Compile the resource with rc /nologo WinDev.rc, then link WinDev.res into the executable.


WinDev ICO Resolutions
======================

Individual ICO files:
- WinDev_16x16.ico
- WinDev_24x24.ico
- WinDev_32x32.ico
- WinDev_48x48.ico
- WinDev_64x64.ico
- WinDev_128x128.ico
- WinDev_256x256.ico

WinDev_MultiResolution.ico contains all listed sizes in one ICO file.
For embedding in a Windows executable, the multi-resolution ICO is generally the most convenient choice.
