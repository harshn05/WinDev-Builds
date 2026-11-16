@echo off

echo.
echo ------------------------------------------------------------
echo  WinDev :: Common Libraries
echo ------------------------------------------------------------

if not defined WINDEV_LIBS (
    echo [WinDev] WINDEV_LIBS is NOT defined.
    exit /b 0
)

set "WINDEV_COMMON_LIBS=%WINDEV_LIBS%\common"
set "OPENBLAS_ROOT=%WINDEV_COMMON_LIBS%\OpenBLAS-0.3.34-x64"

if not exist "%OPENBLAS_ROOT%" (
    echo [WinDev] OpenBLAS NOT FOUND
    exit /b 0
)

set "PATH=%OPENBLAS_ROOT%\bin;%PATH%"
set "CMAKE_PREFIX_PATH=%OPENBLAS_ROOT%;%CMAKE_PREFIX_PATH%"
set "CPLUS_INCLUDE_PATH=%OPENBLAS_ROOT%\include;%CPLUS_INCLUDE_PATH%"
set "INCLUDE=%OPENBLAS_ROOT%\include;%INCLUDE%"
set "LIBRARY_PATH=%OPENBLAS_ROOT%\lib;%LIBRARY_PATH%"
set "LIB=%OPENBLAS_ROOT%\lib;%LIB%"



echo [WinDev] OpenBLAS 0.3.34 : enabled
echo [WinDev] OpenBLAS root   : %OPENBLAS_ROOT%




echo.