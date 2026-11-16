@echo off

rem ============================================================
rem WinDev - MinGW Libraries Environment
rem ============================================================

echo.
echo ------------------------------------------------------------
echo  WinDev :: MinGW Libraries
echo ------------------------------------------------------------


rem ============================================================
rem Validate WinDevLibs
rem ============================================================

if not defined WINDEV_LIBS (
    echo [WinDev] WINDEV_LIBS is not defined.
    echo [WinDev] No MinGW libraries loaded.
    exit /b 0
)

if not exist "%WINDEV_LIBS%\mingw" (
    echo [WinDev] MinGW library directory not found:
    echo          %WINDEV_LIBS%\mingw
    exit /b 0
)


set "WINDEV_MINGW_LIBS=%WINDEV_LIBS%\mingw"

echo [WinDev] MinGW libraries: %WINDEV_MINGW_LIBS%


rem ============================================================
rem Qt
rem ============================================================

set "QT_ROOT=%WINDEV_MINGW_LIBS%\qtbase\6.8.4"

if exist "%QT_ROOT%" (
    set "PATH=%QT_ROOT%\bin;%PATH%"
    set "CMAKE_PREFIX_PATH=%QT_ROOT%;%CMAKE_PREFIX_PATH%"
	set "CPLUS_INCLUDE_PATH=%QT_ROOT%\include;%CPLUS_INCLUDE_PATH%"
	set "LIBRARY_PATH=%QT_ROOT%\lib;%LIBRARY_PATH%"



    echo [WinDev] Qt 6.8.4       : enabled
) else (
    echo [WinDev] Qt 6.8.4       : not found
)


rem ============================================================
rem VTK
rem ============================================================

set "VTK_ROOT=%WINDEV_MINGW_LIBS%\vtk\9.4.2"

if exist "%VTK_ROOT%" (
    set "PATH=%VTK_ROOT%\bin;%PATH%"
    set "CMAKE_PREFIX_PATH=%VTK_ROOT%;%CMAKE_PREFIX_PATH%"
	set "CPLUS_INCLUDE_PATH=%VTK_ROOT%\include;%CPLUS_INCLUDE_PATH%"
    set "LIBRARY_PATH=%VTK_ROOT%\lib;%LIBRARY_PATH%"

    echo [WinDev] VTK 9.4.2       : enabled
) else (
    echo [WinDev] VTK 9.4.2       : not found
)





rem ============================================================
rem Armadillo
rem ============================================================

set "ARMADILLO_ROOT=%WINDEV_MINGW_LIBS%\armadillo\15.4.2"

if exist "%ARMADILLO_ROOT%" (
    set "PATH=%ARMADILLO_ROOT%\bin;%PATH%"
    set "CMAKE_PREFIX_PATH=%ARMADILLO_ROOT%;%CMAKE_PREFIX_PATH%"
    set "CPLUS_INCLUDE_PATH=%ARMADILLO_ROOT%\include;%CPLUS_INCLUDE_PATH%"
    set "LIBRARY_PATH=%ARMADILLO_ROOT%\lib;%LIBRARY_PATH%"

    echo [WinDev] Armadillo 15.4.2  : enabled
) else (
    echo [WinDev] Armadillo 15.4.2  : not found
)



rem ============================================================
rem Common Libraries
rem ============================================================

call "%ConEmuBaseDir%\_Toolchains\loadenv_Common_Libs.cmd"

echo [WinDev] CPLUS_INCLUDE_PATH=%CPLUS_INCLUDE_PATH%
echo [WinDev] LIBRARY_PATH=%LIBRARY_PATH%
echo.


echo.
echo [WinDev] MinGW library environment initialized.
echo.





