# Portable Development Tools & Directory Reference

This repository/directory houses a portable Windows development environment (`Programs/`). It is organized using a clean, modular architecture that separates full software packages from direct command-line launchers and standalone binaries.

---

## 🏗️ Directory Architecture & How It Works

To keep the root directory clean and avoid cluttering the system `PATH` with dozens of nested subfolders, the tools are organized into three distinct components:

1. **Program Folders (Directories)**  
   These folders contain the complete, portable software distributions downloaded directly from their official sources (e.g., `cmake/`, `nvim/`, `PortableGit/`, `vscode/`).
2. **Wrapper Command Scripts (`.cmd`)**  
   Located in the root directory, these lightweight batch scripts act as entry points that invoke the actual executables housed inside their respective program folders. For example, running `cmake.cmd` invokes `cmake.exe` from inside the `cmake/` directory, and `nvim.cmd` launches Neovim from `nvim/`.
3. **Standalone Executables (`.exe`)**  
   Single-binary tools that do not require complex directory trees or external assets are placed directly in the root directory (e.g., `rg.exe`, `fd.exe`, `tinta.exe`, `7z.exe`) so they can be executed immediately from the command line.

> **Note on `cpldd`:**  
> Both `cpldd.exe` and `cpldd.py` are included in the root directory and are sourced from [harshn05/cpldd](https://github.com/harshn05/cpldd). While the Python source script (`cpldd.py`) is kept alongside the standalone executable for reference and flexibility, please note that it is subject to future changes and updates.

---

## 📁 Program Folders (Downloaded Distributions)

These directories contain the full portable installations of core development tools and editors:

* **`cmake/`**: Cross-platform build system generator.
* **`conan/`**: Decentralized C and C++ package manager.
* **`Cppcheck/`**: Static analysis tool for detecting bugs and undefined behavior in C/C++ code.
* **`doxygen/`**: Documentation generator that builds reference manuals from annotated source code.
* **`graphviz/`**: Graph visualization software for rendering structural diagrams and networks.
* **`helix/`**: Post-modern modal text editor with built-in language server support.
* **`notepad++/`**: Feature-rich source code and text editor for Windows.
* **`nvim/`**: Neovim, a hyperextensible Vim-based text editor.
* **`PortableGit/`**: Self-contained Git version control system and Unix-like shell utilities.
* **`swigwin/`**: Simplified Wrapper and Interface Generator (connects C/C++ code with high-level languages like Python and Java).
* **`vscode/`**: Visual Studio Code portable distribution.

---

## ⚙️ Wrapper Scripts (`.cmd` Launchers)

These scripts reside in the root folder and forward execution and arguments to the binaries inside the program folders above:

* **`cmake.cmd` / `cmake-gui.cmd`**: Invokes the CMake CLI or GUI from `cmake/`.
* **`code.cmd`**: Launches Visual Studio Code from `vscode/`.
* **`conan.cmd`**: Runs the Conan package manager from `conan/`.
* **`cpack.cmd`**: Invokes CPack (CMake's packaging tool) from `cmake/`.
* **`cppcheck.cmd` / `cppcheck-gui.cmd`**: Launches Cppcheck CLI or GUI from `Cppcheck/`.
* **`ctest.cmd`**: Runs CTest (CMake's test driver) from `cmake/`.
* **`dot.cmd`**: Invokes Graphviz's `dot` layout engine from `graphviz/`.
* **`doxygen.cmd`**: Runs the Doxygen documentation generator from `doxygen/`.
* **`hx.cmd`**: Launches the Helix editor from `helix/`.
* **`npp.cmd`**: Opens Notepad++ from `notepad++/`.
* **`nvim.cmd`**: Launches Neovim from `nvim/`.
* **`swig.cmd`**: Invokes SWIG from `swigwin/`.
* **`yazi.cmd`**: Wrapper script for launching the Yazi terminal file manager.

---

## 🚀 Standalone Executables (`.exe` & Scripts in Root)

These single-file binaries and scripts sit directly in the root directory for instant execution:

### 1. Build Systems, Compilers & Package Managers
* **`ccache.exe`**: Compiler cache that speeds up recompilation of C/C++ code.
* **`jom.exe`**: Parallel `nmake` alternative for speeding up Qt and MSVC builds.
* **`just.exe`**: Modern command runner for executing project-specific recipes.
* **`ninja.exe`**: Small, high-speed build system often paired with CMake.
* **`ruff.exe`**: Extremely fast Python linter and code formatter.
* **`uv.exe` / `uvx.exe` / `uvw.exe`**: Ultra-fast Python package installer, resolver, and project manager.

### 2. Code Analysis, Deployment & Document Processing
* **`clang-format.exe`**: Automated code formatter for C, C++, Java, JavaScript, and more.
* **`cpldd.exe` / `cpldd.py`**: Windows deployment utility for Qt and non-Qt C/C++ executables that resolves and copies non-system DLL dependencies via `ldd` (sourced from [harshn05/cpldd](https://github.com/harshn05/cpldd); `cpldd.py` is subject to future updates).
* **`MarkdownEditor.exe`**: Dedicated GUI editor for writing and previewing Markdown (`.md`) files.
* **`pandoc.exe`**: Universal markup and document converter (Markdown, PDF, DOCX, HTML, LaTeX).
* **`typst.exe`**: Modern, fast markup-based typesetting system designed as an alternative to LaTeX.

### 3. Terminal Utilities, Search & File Management
* **`fd.exe`**: Fast, user-friendly alternative to the traditional `find` command.
* **`fs.exe`**: File system utility / fast file search executable.
* **`fzf.exe`**: Interactive command-line fuzzy finder for files, history, and processes.
* **`hyperfine.exe`**: Command-line benchmarking tool for measuring execution speed.
* **`lazygit.exe`**: Terminal UI (TUI) for managing Git repositories effortlessly.
* **`nano.exe`**: Lightweight, terminal-based text editor.
* **`nu.exe`**: Nushell, a modern shell that treats data and command outputs as structured tables.
* **`rg.exe`**: Ripgrep, an ultra-fast recursive regex text search tool.
* **`tinta.exe`**: CLI utility for adding color and styling to terminal text output.
* **`tokei.exe`**: Fast code statistics tool that counts files, lines of code, comments, and blanks by language.
* **`yazi.exe`**: Blazing-fast terminal file manager written in Rust.

### 4. Compression & Downloading
* **`7z.exe`**: 7-Zip command-line archiver for compressing and extracting archives (`.7z`, `.zip`, `.tar`, etc.).
* **`aria2c.exe`**: Lightweight, multi-protocol, multi-source command-line download utility.
* **`zstd.exe`**: Zstandard real-time lossless data compression tool.
