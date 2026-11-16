@echo off

rem ============================================================
rem WinDev - MSVC Libraries Environment
rem ============================================================

echo.
echo ------------------------------------------------------------
echo  WinDev :: MSVC Libraries
echo ------------------------------------------------------------

if not defined WINDEV_LIBS (
    echo [WinDev] WINDEV_LIBS is not defined.
    echo [WinDev] No MSVC libraries loaded.
    exit /b 0
)

if not exist "%WINDEV_LIBS%\msvc" (
    echo [WinDev] MSVC library directory not found:
    echo          %WINDEV_LIBS%\msvc
    exit /b 0
)

set "WINDEV_MSVC_LIBS=%WINDEV_LIBS%\msvc"

echo [WinDev] MSVC libraries: %WINDEV_MSVC_LIBS%

rem ============================================================
rem Qt
rem ============================================================

set "QT_ROOT=%WINDEV_MSVC_LIBS%\qtbase\6.8.4"

if exist "%QT_ROOT%" (
    set "PATH=%QT_ROOT%\bin;%PATH%"
    set "CMAKE_PREFIX_PATH=%QT_ROOT%;%CMAKE_PREFIX_PATH%"
	set "INCLUDE=%QT_ROOT%\include;%INCLUDE%"
    set "LIB=%QT_ROOT%\lib;%LIB%"

    echo [WinDev] Qt 6.8.4       : enabled
) else (
    echo [WinDev] Qt 6.8.4       : not found
)



rem ============================================================
rem Armadillo
rem ============================================================

set "ARMADILLO_ROOT=%WINDEV_MSVC_LIBS%\armadillo\15.4.2"

if exist "%ARMADILLO_ROOT%" (
    set "PATH=%ARMADILLO_ROOT%\bin;%PATH%"
    set "CMAKE_PREFIX_PATH=%ARMADILLO_ROOT%;%CMAKE_PREFIX_PATH%"
    set "INCLUDE=%ARMADILLO_ROOT%\include;%INCLUDE%"
    set "LIB=%ARMADILLO_ROOT%\lib;%LIB%"

    echo [WinDev] Armadillo 15.4.2  : enabled
) else (
    echo [WinDev] Armadillo 15.4.2  : not found
)



rem ============================================================
rem Common Libraries
rem ============================================================

call "%ConEmuBaseDir%\_Toolchains\loadenv_Common_Libs.cmd"


rem ============================================================
rem Future libraries
rem ============================================================
rem
rem VTK
rem ----
rem set "VTK_ROOT=%WINDEV_MSVC_LIBS%\vtk\..."
rem
rem ITK
rem ----
rem set "ITK_ROOT=%WINDEV_MSVC_LIBS%\itk\..."
rem
rem OpenCV
rem ------
rem set "OpenCV_ROOT=%WINDEV_MSVC_LIBS%\opencv\..."
rem

echo.
echo [WinDev] MSVC library environment initialized.
echo.





echo [WinDev] INCLUDE=%INCLUDE%
echo [WinDev] LIB=%LIB%
echo.