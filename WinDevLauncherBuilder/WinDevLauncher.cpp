#define UNICODE
#define _UNICODE
#include <windows.h>
#include <shellapi.h>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

namespace fs = std::filesystem;

static std::wstring GetExeDirectory() {
    std::vector<wchar_t> buffer(32768);
    DWORD length = GetModuleFileNameW(nullptr, buffer.data(), static_cast<DWORD>(buffer.size()));
    if (length == 0 || length >= buffer.size()) return L".";
    return fs::path(std::wstring(buffer.data(), length)).parent_path().wstring();
}

static bool RunBatch(const fs::path& script) {
    if (!fs::exists(script)) {
        std::wcerr << L"\n[WinDev] Launcher script not found:\n  " << script.wstring() << L"\n\n";
        std::wcout << L"Press Enter to return to the menu...";
        std::wstring ignored;
        std::getline(std::wcin, ignored);
        return false;
    }

    // Keep the current console so diagnostics and existing pause/error handling remain visible.
    std::wstring command = L"cmd.exe /d /c call \"" + script.wstring() + L"\"";
    std::vector<wchar_t> mutableCommand(command.begin(), command.end());
    mutableCommand.push_back(L'\0');

    STARTUPINFOW si{};
    si.cb = sizeof(si);
    PROCESS_INFORMATION pi{};
    BOOL ok = CreateProcessW(
        nullptr,
        mutableCommand.data(),
        nullptr, nullptr,
        TRUE,
        0,
        nullptr,
        GetExeDirectory().c_str(),
        &si, &pi);

    if (!ok) {
        std::wcerr << L"\n[WinDev] Could not start launcher. Windows error: " << GetLastError() << L"\n";
        std::wcout << L"Press Enter to return to the menu...";
        std::wstring ignored;
        std::getline(std::wcin, ignored);
        return false;
    }

    WaitForSingleObject(pi.hProcess, INFINITE);
    DWORD exitCode = 1;
    GetExitCodeProcess(pi.hProcess, &exitCode);
    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);

    if (exitCode != 0) {
        std::wcout << L"\n[WinDev] Launcher exited with code " << exitCode << L".\n";
        std::wcout << L"Press Enter to return to the menu...";
        std::wstring ignored;
        std::getline(std::wcin, ignored);
    }
    return exitCode == 0;
}





static void PrintMenu() {
    HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);

    // Enable ANSI / Virtual Terminal processing.
    DWORD mode = 0;
    bool ansi = GetConsoleMode(hOut, &mode) &&
                SetConsoleMode(hOut, mode | ENABLE_VIRTUAL_TERMINAL_PROCESSING);

    // Fallback to ordinary output if ANSI is unavailable.
    auto print = [&](const wchar_t* text) {
        DWORD written = 0;
        if (hOut != INVALID_HANDLE_VALUE &&
            hOut != nullptr && GetConsoleMode(hOut, &mode)) {
            WriteConsoleW(hOut, text,
                static_cast<DWORD>(wcslen(text)),
                &written, nullptr);
        }
    };

    system("cls");

    const wchar_t* RESET = L"\x1b[0m";
    const wchar_t* DIM   = L"\x1b[2m";
    const wchar_t* BOLD  = L"\x1b[1m";
    const wchar_t* CYAN  = L"\x1b[96m";
    const wchar_t* LINE  = L"\x1b[90m";

    const wchar_t* colors[] = {
        L"\x1b[38;2;80;140;255m",
        L"\x1b[38;2;70;170;255m",
        L"\x1b[38;2;60;205;230m",
        L"\x1b[38;2;65;220;175m",
        L"\x1b[38;2;130;225;125m",
        L"\x1b[38;2;195;225;100m"
    };

    const wchar_t* logo[] = {
        L"  ██╗    ██╗██╗███╗   ██╗██████╗ ███████╗██╗   ██╗\n",
        L"  ██║    ██║██║████╗  ██║██╔══██╗██╔════╝██║   ██║\n",
        L"  ██║ █╗ ██║██║██╔██╗ ██║██║  ██║█████╗  ██║   ██║\n",
        L"  ██║███╗██║██║██║╚██╗██║██║  ██║██╔══╝  ╚██╗ ██╔╝\n",
        L"  ╚███╔███╔╝██║██║ ╚████║██████╔╝███████╗ ╚████╔╝\n",
        L"   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝  ╚═══╝\n"
    };

    for (int i = 0; i < 6; ++i) {
        if (ansi) print(colors[i]);
        print(logo[i]);
        if (ansi) print(RESET);
    }

    if (ansi) print(L"\x1b[90m");
    print(L"\n  ─────────────────────────────────────────────────\n");

    if (ansi) print(BOLD);
    print(L"      PORTABLE  ·  SCIENTIFIC  ·  DEVELOPMENT\n");
    if (ansi) print(RESET);

    if (ansi) print(CYAN);
    print(L"             harsh.narula@iitbombay.org\n");

    if (ansi) print(DIM);
    print(L"             © 2026 Harsh Kumar Narula\n");

    if (ansi) print(LINE);
    print(L"  ─────────────────────────────────────────────────\n\n");

    if (ansi) print(RESET);
    if (ansi) print(CYAN);
    print(L"  [1]  ");
    if (ansi) print(RESET);
    print(L"Windows Terminal\n");

    if (ansi) print(CYAN);
    print(L"  [2]  ");
    if (ansi) print(RESET);
    print(L"ConEmu\n");

    if (ansi) print(CYAN);
    print(L"  [3]  ");
    if (ansi) print(RESET);
    print(L"Alacritty + Zellij\n\n");

    if (ansi) print(DIM);
    print(L"  [Q]  Exit\n\n");

    if (ansi) print(BOLD);
    print(L"  Select terminal: ");
    if (ansi) print(RESET);
}



int wmain() {
    SetConsoleOutputCP(CP_UTF8);
    SetConsoleCP(CP_UTF8);
    const fs::path root(GetExeDirectory());

    for (;;) {
        PrintMenu();
        std::wstring choice;
        if (!std::getline(std::wcin, choice)) return 0;
        if (choice == L"q" || choice == L"Q") return 0;

        fs::path script;
        if (choice == L"1") script = root / L"WinDev.cmd";
        else if (choice == L"2") script = root / L"WinDev-ConEmu.cmd";
        else if (choice == L"3") script = root / L"WinDev-Alacritty.cmd";
        else continue;

        // On successful launch, close the menu instead of returning to it.
        // On failure, RunBatch keeps its error prompt and we return to the menu.
        if (RunBatch(script)) return 0;
    }
}
