//gcc -O3 launch.c -o launch.exe -mwindows -municode -Wall -Wextra
//cl /O2 /Fe:launch.exe launch.c /link /SUBSYSTEM:WINDOWS /ENTRY:wWinMainCRTStartup /W4
// clang-cl /O2 /Fe:launch.exe launch.c /link /SUBSYSTEM:WINDOWS /ENTRY:wWinMainCRTStartup /W4
// clang -O3 launch.c -o launch.exe -mwindows -DUNICODE -D_UNICODE -Wl,-entry:wWinMainCRTStartup -Wall -Wextra

#define UNICODE
#define _UNICODE
#include <windows.h>
#include <wchar.h>
#include <stdio.h>

int WINAPI wWinMain(HINSTANCE hInstance,
                    HINSTANCE hPrevInstance,
                    PWSTR pCmdLine,
                    int nCmdShow)
{
    wchar_t exePath[MAX_PATH];
    wchar_t batPath[MAX_PATH];
    wchar_t cmdPath[MAX_PATH];
    wchar_t commandLine[MAX_PATH * 2];

    // Find the directory containing this launcher.exe
    DWORD len = GetModuleFileNameW(NULL, exePath, MAX_PATH);
    if (len == 0 || len >= MAX_PATH)
        return 1;

    wchar_t *lastSlash = wcsrchr(exePath, L'\\');
    if (!lastSlash)
        return 1;

    *(lastSlash + 1) = L'\0';

    // launch.bat in the same portable directory
    if (swprintf(batPath, MAX_PATH, L"%slaunch.bat", exePath) < 0)
        return 1;

    // Full path to Windows cmd.exe
    UINT sysLen = GetSystemDirectoryW(cmdPath, MAX_PATH);
    if (sysLen == 0 || sysLen >= MAX_PATH)
        return 1;

    if (wcscat_s(cmdPath, MAX_PATH, L"\\cmd.exe") != 0)
        return 1;

    // Correctly quote the batch file path
    if (swprintf(commandLine, MAX_PATH * 2,
                 L"cmd.exe /d /s /c \"\"%s\"\"",
                 batPath) < 0)
        return 1;

    STARTUPINFOW si = {0};
    PROCESS_INFORMATION pi = {0};
    si.cb = sizeof(si);
    si.dwFlags = STARTF_USESHOWWINDOW;
    si.wShowWindow = SW_HIDE;

    // Start the batch file without creating a visible console
    BOOL ok = CreateProcessW(
        cmdPath,
        commandLine,
        NULL, NULL,
        FALSE,
        CREATE_NO_WINDOW,
        NULL, NULL,
        &si, &pi
    );

    if (!ok)
        return 2;

    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);

    return 0;
}
