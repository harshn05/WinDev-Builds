WinDev Launcher prototype
=========================

What it does
------------
A small native C++ console menu that offers:
  1. Windows Terminal
  2. ConEmu
  3. Alacritty + Zellij

It finds its own directory and calls the corresponding existing CMD launcher.
It does not assume WinDev is installed at a fixed path.
After a launcher script returns success, the menu exits instead of reappearing.
If launching fails, the error is shown and the menu remains available.

Expected layout
---------------
WinDev.exe
WinDev.cmd
WinDev-ConEmu.cmd
WinDev-Alacritty.cmd
WinDev-Base\ (or WinDev-Base.iso)
...

IMPORTANT
---------
This is a menu/front-end prototype, not yet a full migration of launcher logic.
The existing CMD files remain required and editable, so this prototype does NOT
provide implementation protection yet. It is useful for validating the menu and
preserving current behaviour before moving the core logic into C++.

Build using the portable MSVC developer environment
---------------------------------------------------
Open the WinDev MSVC environment, change directory to the folder containing
WinDevLauncher.cpp, and run:

  rc /nologo WinDev.rc
  cl /O2 /nologo /std:c++17 /utf-8 /EHsc /W4 WinDevLauncher.cpp WinDev.res /Fe:WinDev.exe

No additional runtime or third-party library is required for this console app.

Before testing
--------------
1. Make sure the main launcher is named WinDev.cmd in the same directory.
   The uploaded reference was named WinDev(20261018-204326).cmd; use the actual
   working WinDev.cmd in your WinDev folder, not that timestamped filename.
2. Keep all three CMD files until all terminal options have been tested.
3. Test folder mode and ISO mode before distributing the EXE.
