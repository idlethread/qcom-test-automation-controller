# Qualcomm Test Automation Controller (QTAC)

[![CMake Build](https://github.com/qualcomm/qcom-test-automation-controller/actions/workflows/build.yml/badge.svg)](https://github.com/qualcomm/qcom-test-automation-controller/actions/workflows/build.yml)

## Table of Contents
- [Introduction](#introduction)
- [What You Get](#what-you-get)
- [Hardware Requirements](#hardware-requirements)
- [Common Prerequisites](#common-prerequisites)
- [Windows Guide](#windows-guide)
- [Linux Guide](#linux-guide)
- [Library-only Build](#library-only-build)
- [Installing the Libraries](#installing-the-libraries)
- [Repository Structure](#repository-structure)
- [Application Dependency Architecture](#application-dependency-architecture)
- [Advanced Topics](#advanced-topics)
- [Support & Contributing](#support--contributing)

## Introduction

QTAC is a software suite that enables users to control Qualcomm devices remotely via a Qualcomm approved debug board connected to a host.

## What You Get

| Application | Description |
| :--- | :--- |
| **Test Automation Controller (TAC)** | Control Qualcomm devices remotely using UI |
| **TAC Configuration Editor** | Design configurable TAC UI based on GPIO use-cases |
| **Device Catalog** | Program debug board and view supported Qualcomm platforms |
| **Command-line utilities** | DevList, FTDICheck, LITEProgrammer, PSOCProgrammer, TACDump, UpdateDeviceList |

![QTAC UI Overview](./docs/resources/qtac-sw-suite.png)

## Hardware Requirements

**Required Hardware**:
- Qualcomm approved debug board (FTDI, Cypress PSoC5LP or Microchip PIC32CX SG41-based)
- Qualcomm device to be controlled
- USB Cables: Type B Micro-USB (Board to Host) & Type-C (Device to Host)

**Setup**: Connect the device to the debug board (directly or via cable strip) and both to the host.

> [!IMPORTANT]
> PSOC debug boards must be factory-programmed with firmware. If the board isn't recognized, it likely lacks programming.

![QTAC Hardware Software Setup](./docs/resources/qtac-setup-overview.drawio.png)

## Common Prerequisites

### Development Tools

| Category | Software | Minimum Version |
| :-- | :-- | :-- |
| **OS** | Windows / Debian | Windows 10+ / Ubuntu 22.04+ |
| **Compiler** | [MSVC 2022](https://aka.ms/vs/17/release/vs_community.exe) / GCC | MSVC 2022 / GCC-11, G++-11, GLIBC-2.35 |
| **UI Framework** | [Qt Open-source](https://www.qt.io/download-qt-installer-oss) | 6.9.0+ |

> [!NOTE]
> Review license terms for [Visual Studio](https://visualstudio.microsoft.com/license-terms/) and [Qt](https://www.qt.io/development/download-open-source). MSVC 2022 is linked as Qt doesn't support MSVC 2026 yet.

### Drivers

- **[FTDI D2XX drivers](https://ftdichip.com/drivers/d2xx-drivers/)**: For debug board interaction.
- **[Qualcomm USB Drivers](https://softwarecenter.qualcomm.com/catalog/item/Qualcomm_Userspace_Driver)**: To view device status.

> [!NOTE]
> FTDI libraries are installed _automatically_ during the cmake configuration step when building from source.

### Optional Software

QTAC allows you to view streaming device logs as you transition the device between different states. The debug logs are streamed over USB serial interface(s).

To view these logs, you may install [Putty](https://www.putty.org/) or similar terminal software. QTAC does not depend on or use this software.

### Clone Repository

```bash
git clone https://github.com/qualcomm/qcom-test-automation-controller.git
```

## Windows Guide

### Configuration

1. **Visual Studio**: Install **Desktop development with C++** and **.NET desktop development**.
   ![Desktop development with C++](./docs/resources/qtac-msvc-2022-requirements.png)
2. **Qt**: Install Qt 6.9+ for **MSVC 2022 64-bit**, **Qt Serial Port** and **Qt Multimedia** components.
   
> [!NOTE]
> Installation using Qt Online Installer will require users to create a Qt account.
3. **Environment Variable**:
   ```cmd
   setx QTBIN C:\Qt\<version>\msvc2022_64\bin
   ```

### Build & Usage

Execute `build.bat` to generate executables:

```cmd
build.bat
```

**Build output**:
- Debug: `__Builds\x64\Debug`
- Release: `__Builds\x64\Release`

**Usage**:
```cmd
__Builds\x64\Release\QTAC.exe
```

## Linux Guide

### Configuration

> [!IMPORTANT]
> - Installation using Qt Online Installer will require users to create a Qt account.
> - If you're frequently working with Qt on Linux, consider adding the environment variables to `.bashrc`.
> - Using `sudo apt install <package>` will update setup packages. Review command usage to prevent issues with other applications.

1. **Qt Installation** (choose one):
   
   **Option A**: Qt Online Installer
   - Install Qt 6.9+ for **GCC 64-bit** and **Qt Serial Port** component using [Qt Online Installer](https://www.qt.io/download-qt-installer-oss)
   
   **Option B**: Quick Installation via apt
   ```bash
   sudo apt install qt6-base-dev qt6-serialport-dev
   ```
2. **Runtime Dependencies**:
   ```bash
   sudo apt install libxcb-cursor0 libpcre2-16-0 libxkbcommon-x11-0 libxcb-xkb1 libxcb-icccm4 libxcb-shape0 libxcb-keysyms1 libgl1 libegl-dev libxcb-xinerama0 libpulse-dev
   ```
3. **Environment Variable**:
   ```bash
   export QTBIN=/path/to/Qt/directory/<version>/gcc_64/bin
   ```

### Build & Usage

Execute `build.sh` to generate executables:

```bash
./build.sh
```

**Build output**:
- Debug: `__Builds/Linux/Debug`
- Release: `__Builds/Linux/Release`

> [!NOTE]
> Ensure that [make](https://www.gnu.org/software/make/) is available in your environment before building.

**Usage**:
```bash
./__Builds/Linux/Release/QTAC
```

## Library-only Build

Pass `--lib-only` to `build.sh` (or `-DBUILD_UI=OFF` to CMake directly) to
build only `QCommonConsole` and `TACDev`, skipping all GUI applications and
the Qt Widgets / Gui / Multimedia modules.

> [!IMPORTANT]
> **Qt is still required.** `QCommonConsole` uses Qt as its core framework
> (serial port I/O, XML parsing, networking, threading). The `--lib-only`
> flag removes the *graphical* Qt dependency, not Qt itself. Minimum
> required components: Core, Concurrent, SerialPort, Network, Xml.

### What you get

| Output | Description |
| :-- | :-- |
| `QCommonConsole` | Headless device-control library. Handles FTDI/PSoC/PIC32CX boards, loads `.tcnf` board configurations, drives the TAC protocol. |
| `TACDev` | Thin `extern "C"` wrapper over `QCommonConsole`. Its public API (`TACDev.h`) uses only primitive C types — no Qt or QCommonConsole types leak through — making it suitable for use from Python, Java, C# or any language with a C FFI. |

`TACDev` cannot be built or linked without `QCommonConsole` (it references
its symbols directly), and the `.tcnf` board configuration files are parsed
by `QCommonConsole` — there is no independent loader.

### Build

**Linux** (Qt via apt, no QTBIN needed):
```bash
sudo apt install qt6-base-dev qt6-serialport-dev
./build.sh --lib-only
```

**Linux** (Qt Online Installer):
```bash
export QTBIN=/path/to/Qt/<version>/gcc_64/bin
./build.sh --lib-only
```

**Windows**:
```cmd
set QTBIN=C:\Qt\<version>\msvc2022_64\bin
build.bat
cmake -S . -B build\Release ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_UI=OFF
cmake --build build\Release
```

**Build output**: `QCommonConsole` and `TACDev` static libraries under
`__Builds/Linux/Release/lib/` (Linux) or `__Builds/x64/Release/lib/` (Windows).

The platform configuration files in `configurations/` are plain `.tcnf`
data files and require no build step; copy them alongside the application.

## Installing the Libraries

`cmake --install` places the libraries, the `TACDev.h` public header, and
the `.tcnf` board configurations into standard system directories so
wrappers and downstream projects can consume them without referencing the
build tree.

**What gets installed**

| Path | Contents |
| :-- | :-- |
| `<prefix>/lib/` | `libQCommonConsole.a`, `libTACDev.a`, `libftd2xx.a` (Linux) / `libftd2xx.dylib` (macOS) |
| `<prefix>/include/qtac/` | `TACDev.h` — public C API |
| `<prefix>/share/qtac/configurations/` | All `.tcnf` board configuration files |

### macOS — Homebrew

**Option A: local tap** (tracked by Homebrew, supports `brew uninstall`):
```bash
brew tap-new --no-git local/qtac
cp Formula/qtac.rb $(brew --repository)/Library/Taps/local/homebrew-qtac/Formula/
brew install --HEAD local/qtac/qtac
```

**Option B: direct install** (simpler, no uninstall tracking):
```bash
./build.sh --lib-only
cmake --install build/Release --prefix $(brew --prefix)
```

### Linux

```bash
./build.sh --lib-only
sudo cmake --install build/Release          # installs to /usr/local
```

To use a custom prefix (e.g. to avoid `sudo`):
```bash
cmake --install build/Release --prefix ~/.local
```

## Repository Structure

| Directory | Content |
| :-- | :-- |
| `.github` | CI/CD build pipelines |
| `configurations` | Platform-specific pin configurations |
| `docs` | Documentation and guides |
| `examples` | Device-control automation scripts |
| `interfaces` | APIs for C++, Python, C#, and Java |
| `src` | Source files (Applications & Libraries) |
| `third-party` | External dependency scripts |

## Application Dependency Architecture

![App dependency](./docs/resources/app-dependency.drawio.png)

## Advanced Topics

- [Build Using Qt Creator](./docs/getting-started/01-Build-Using-Qt-Creator.md)
- [Python API Guide](./docs/bootcamp/01-Bootcamp.md)

## Support & Contributing

- **Security**: Review [SECURITY.md](./.github/SECURITY.md) for vulnerability reporting.
- **Contributing**: Review [License](./LICENSE) and [Code of Conduct](./CODE-OF-CONDUCT.md).
