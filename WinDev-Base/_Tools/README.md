# Developer Tools & Directories Reference

This document categorizes the provided items into **Folders (Directories)** and **Tools (Executables & Command Scripts)** based on their primary functions.

---

## 📁 Folders (Directories)

These items represent main software packages or portable setups without file extensions:

* **cmake**: Main directory for the cross-platform build system generator.
* **conan**: Directory for the decentralized C and C++ package manager.
* **Cppcheck**: Directory for the static analysis tool that detects bugs and errors in C/C++ code.
* **doxygen**: Directory for the tool that automatically generates documentation from annotated source code.
* **graphviz**: Directory for open-source graph and network diagram visualization software.
* **helix**: Directory for the modern, post-modern modal text editor (similar to Vim/Neovim).
* **notepad++**: Directory for the popular source code editor for Windows.
* **nvim**: Main directory for Neovim, a hyperextensible Vim-based text editor.
* **PortableGit**: Directory for the portable version of the Git version control system.
* **swigwin**: Windows directory for SWIG (Simplified Wrapper and Interface Generator), which connects C/C++ with languages like Python and Java.
* **vscode**: Main portable or installation directory for Visual Studio Code.

---

## 🛠️ Tools (Executables & Command Scripts)

These executables and scripts are grouped by their primary workflow category:

### 1. Code Editors & IDEs (Launchers)
* **code.cmd**: Command script to launch Visual Studio Code from the terminal.
* **hx.cmd**: Command script to launch the Helix text editor.
* **MarkdownEditor.exe**: Dedicated editor for writing and previewing Markdown (`.md`) files.
* **nano.exe**: Simple, terminal-based text editor.
* **npp.cmd**: Command script to launch Notepad++ from the command line.
* **nvim.cmd**: Command script to launch the Neovim text editor.

### 2. Build Systems, Compilers & Package Managers (C/C++ & Python)
* **ccache.exe**: Compiler cache that speeds up recompilation of C/C++ code.
* **cmake.cmd / cmake-gui.cmd**: Command scripts to run CMake via CLI or its graphical user interface.
* **conan.cmd**: Command script to run the Conan C/C++ package manager.
* **cpack.cmd**: Packaging tool bundled with CMake for creating installers and distribution packages.
* **ctest.cmd**: Test driver tool bundled with CMake for running automated project tests.
* **jom.exe**: Parallel `nmake` clone for faster multi-core builds, primarily used in Qt projects.
* **just.exe**: Modern command runner (similar to `make`) for executing project-specific recipes.
* **ninja.exe**: Small, high-speed build system commonly used alongside CMake.
* **ruff.exe**: Extremely fast Python linter and code formatter written in Rust.
* **swig.cmd**: Command script to execute SWIG from the command line.
* **uv.exe / uvx.exe / uvw.exe**: Ultra-fast Python package installer, tool runner, and project manager written in Rust.

### 3. Code Analysis, Formatting & Documentation
* **clang-format.exe**: Automated code formatting tool for C, C++, Java, JavaScript, and other languages.
* **cpldd.exe / cpldd.py**: Tool (similar to Linux `ldd`) for inspecting DLL dependencies of Windows executables (`.exe`).
* **cppcheck.cmd / cppcheck-gui.cmd**: Command scripts to launch the Cppcheck static analyzer in CLI or GUI mode.
* **dot.cmd**: Graphviz command-line tool that renders diagram images from plain-text graph descriptions.
* **doxygen.cmd**: Command script to generate documentation from source code comments.
* **pandoc.exe**: Universal document converter supporting Markdown, PDF, Word, HTML, and more.
* **typst.exe**: Modern, fast markup-based typesetting system serving as an alternative to LaTeX.

### 4. Terminal Utilities, Search & File Management
* **fd.exe**: Fast, user-friendly alternative to the traditional `find` command.
* **fs.exe**: File system utility or fast file search tool.
* **fzf.exe**: Interactive command-line fuzzy finder for files, command history, and processes.
* **hyperfine.exe**: Command-line benchmarking tool for measuring program execution speed.
* **lazygit.exe**: Simple terminal user interface (TUI) for managing Git repositories.
* **nu.exe**: Nushell, a modern shell that treats data and command outputs as structured tables.
* **rg.exe**: Ripgrep, an ultra-fast line-oriented text search tool for files and directories.
* **tinta.exe**: Utility tool for adding colors and text styling to terminal output.
* **tokei.exe**: Code statistics tool that counts lines of code, comments, and blanks across programming languages.
* **yazi.exe / yazi.cmd**: Blazing-fast terminal file manager written in Rust.

### 5. Compression & Downloading
* **7z.exe**: 7-Zip command-line file archiver for compressing and extracting formats like `.zip`, `.7z`, and `.rar`.
* **aria2c.exe**: Lightweight multi-protocol, multi-source command-line download utility.
* **zstd.exe**: Zstandard fast real-time data compression and decompression tool.
