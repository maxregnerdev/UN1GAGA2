<h1 align="center">
  <img loading="lazy" src="readme-res/banner.png"/>
</h1>
<p align="center">
  <a href="https://github.com/maxregnerdev/UN1GAGA2/blob/sixteen/LICENSE"><img loading="lazy" src="https://img.shields.io/github/license/maxregnerdev/UN1GAGA2?style=for-the-badge&logo=github"/></a>
  <a href="https://github.com/maxregnerdev/UN1GAGA2/commits/sixteen"><img loading="lazy" src="https://img.shields.io/github/last-commit/maxregnerdev/UN1GAGA2/sixteen?style=for-the-badge"/></a>
  <a href="https://github.com/maxregnerdev/UN1GAGA2/stargazers"><img loading="lazy" src="https://img.shields.io/github/stars/maxregnerdev/UN1GAGA2?style=for-the-badge"/></a>
  <a href="https://github.com/maxregnerdev/UN1GAGA2/actions/workflows/ci.yml"><img loading="lazy" src="https://img.shields.io/github/actions/workflow/status/maxregnerdev/UN1GAGA2/ci.yml?style=for-the-badge"/></a>
</p>
<p align="center">UN1CA AIOS <i>(/ˈu.ni.ka/)</i> — a rebuilt operating system for the Samsung Galaxy S8 (dreamlte).</p>

# What is UN1CA AIOS?
UN1CA AIOS is a fully rewritten, ground-up custom Android operating system created specifically for the Samsung Galaxy S8 (Exynos 8895 — dreamlte).

Unlike traditional ROM ports or binary patching tools, UN1CA AIOS replaces the legacy Samsung One UI stack with a completely re-engineered open-source OS base. Built from source with rewritten C++ system daemons, native hardware abstraction layers (HALs), and a custom-compiled graphics pipeline, UN1CA AIOS delivers modern Galaxy AI features, high-end visual blur effects, and lightweight performance on 2017 flagship hardware.

## Operating System Architecture
```
┌─────────────────────────────────────────────────────────────────┐
│                     UN1CA AIOS System Shell                     │
│    (Custom Launcher, System UI, Galaxy AI Native Utilities)    │
├─────────────────────────────────────────────────────────────────┤
│                   Rewritten Java Framework                      │
│   (Extends AOSP Framework with Native One UI & AI APIs)         │
├─────────────────────────────────────────────────────────────────┤
│                     Native C++ Services                         │
│    aiosd (AI Runtime)  •  Vulkan Compositor  •  EROFS HAL      │
├─────────────────────────────────────────────────────────────────┤
│                 Custom Exynos 8895 Linux Kernel                 │
│     (10nm Optimization, ZSTD zRAM, WireGuard, DisplayPort)     │
└─────────────────────────────────────────────────────────────────┘
```

| Subsystem | Rebuilt Implementation Details |
|---|---|
| Device Target | Samsung Galaxy S8 (dreamlte) |
| SoC Base | Exynos 8895 Octa (4× Mongoose M2 @ 2.3 GHz & 4× Cortex-A53 @ 1.7 GHz) |
| Graphics API | Vulkan 1.2 Hardware Compositor (direct GPU rendering pipeline) |
| Filesystem Architecture | Pure EROFS read-only system partitions with inline compression |
| AI Processing Engine | aiosd — re-engineered native C++ inferencing daemon using ARM NEON |
| RAM Subsystem | Custom ZSTD zRAM allocator (2.5 GB pool with real-time compaction) |

# Native Galaxy AI Stack
The entire AI feature matrix is compiled natively into the OS framework, bypassing cloud dependency and minimizing background memory usage:

- **Audio Eraser** — native DSP pipeline to filter background noise from microphone input and media files
- **Browsing Assist** — built-in DOM parser for real-time article translation and summarization inside browser webviews
- **Call Assist** — on-device speech-to-text and text-to-speech translation engine for incoming and outgoing calls
- **Drawing Assist** — vector sketch-to-art generation accelerated via Mali-G71 GPU compute shaders
- **Interpreter** — native split-screen UI service for dual-language real-time voice translation
- **Note Assist** — system-level text formatting, grammar checking, and summarization engine
- **Now Brief** — contextual engine providing unified morning/evening digests, calendar events, and weather insights
- **Photo Assist** — generative image editing, object removal, and background expansion built directly into the gallery HAL
- **Semantic Search** — indexing service providing natural language search across local photos, files, and system settings
- **Transcript Assist** — voice recorder service featuring multi-speaker diarization and automated transcription
- **Writing Assist** — real-time keyboard-integrated tone adjustment and spellchecking

# Visuals & Framework Features
- **Vulkan Render Engine** — complete re-implementation of the System UI compositor utilizing Vulkan graphics pipelines for real-time 60 FPS live blurs across all notification panels and control centers
- **Always-On Display (AOD)** — dynamic vector transition engine between lock screen widgets and AOD clocks
- **Galaxy S25 Asset Ecosystem** — native incorporation of Galaxy S25 wallpapers, notification sounds, ringtones, and adaptive UI iconography
- **Adaptive Display Drivers** — framework-level color tone and simulated adaptive refresh rate scheduling
- **Samsung DeX Support** — fully rewritten hardware HAL enabling wired desktop output via USB-C DisplayPort and wireless screen mirroring
- **Dual Messenger & Multi-User** — native OS multi-account framework unlocked for all installed applications without third-party sandboxing
- **Custom FlipFont Engine** — rewritten font manager supporting system-wide custom typography

# Security, Privacy & Tweak Framework
- **Integrated TrickyStore Key Attestation** — native system service for spoofing key attestation (requires valid keybox file)
- **Built-in Play Integrity Fix** — automatically spoofs device fingerprints to maintain Basic and Device integrity compliance out-of-the-box
- **Knox-Bypass Stack** — native substitution layer allowing Samsung Health, Secure Folder, and Samsung Pass to run seamlessly on unlocked bootloaders
- **Hardware Privacy Controls** — hardware-level toggles in Quick Settings to completely sever camera, microphone, and location feeds
- **Application Governance**
  - System-level application hiding (Hide My Applist protocol built into the package manager)
  - Toggleable Developer Options visibility
  - Native APK downgrade permission overrides
  - Legacy targetSdk execution support
  - Screenshot security restriction bypasses
- **CSC Extra Enhancements**
  - Region-free native call recording
  - Integrated Hiya spam protection
  - Real-time network speed meter in status bar
  - AltZLife secure profile switcher

# Source Layout
```
buildenv.sh                  environment setup + `lunch` target selection
scripts/                     staged build pipeline
  make_rom.sh                download → extract → work dir → patches → mods → APKs → images → zips
  build_native_services.sh   builds aiosd, aios_compositor, erofs_hal
native/
  aiosd/                     AI runtime daemon (ARM NEON inference, audio DSP, local RPC)
  aios_compositor/            Vulkan 1.2 compositor (live blur pipeline)
  erofs_hal/                 EROFS mount HAL shim
aios/
  configs/                   version + system image configs
  patches/                   ROM-level patches (props, framework, SELinux)
  mods/                      feature modules (ai_runtime, graphics, memory, security, dex, ...)
platform/exynos8895/          Exynos 8895 platform config + patches
target/dreamlte/             Galaxy S8 device target config
```

# Building & Installing from Source
## Workspace Setup
```bash
# Initialize the UN1CA AIOS source tree
mkdir un1ca-aios && cd un1ca-aios
git clone -b sixteen https://github.com/maxregnerdev/UN1GAGA2.git .
git submodule update --init --recursive
```

## Build & Flash Sequence
### 1. Environment Initialization
Set up build environment variables and select the device target:
```bash
source buildenv.sh
lunch aios_dreamlte-userdebug
```

### 2. Build Native Services & Execute Compilation
Compile the native C++ daemons, then run the full OS build pipeline:
```bash
aios build_dependencies
aios build_native_services
aios make_rom -z
```
This generates the flashable `UN1CA-AIOS_dreamlte` package inside `out/`.

### 3. Prepare Target Device
Boot your Galaxy S8 into TWRP/OrangeFox recovery. Format `/data` to wipe encryption, and wipe `/system`, `/cache`, and `/dalvik`.

### 4. Flash Firmware Package
Sideload or install the generated UN1CA AIOS zip directly in recovery and reboot to system.

# Licensing
This project is licensed under the terms of the [GNU General Public License v3.0](LICENSE). External dependencies might be distributed under a different license, such as:
- [android-tools](https://github.com/nmeum/android-tools), licensed under the [Apache License 2.0](https://github.com/nmeum/android-tools/blob/master/LICENSE)
- [apktool](https://github.com/iBotPeaches/Apktool), licensed under the [Apache License 2.0](https://github.com/iBotPeaches/Apktool/blob/LICENSE.md)
- [erofs-utils](https://github.com/sekaiacg/erofs-utils/), dual license ([GPL-2.0](https://github.com/sekaiacg/erofs-utils/blob/dev/LICENSES/GPL-2.0), [Apache-2.0](https://github.com/sekaiacg/erofs-utils/blob/dev/LICENSES/Apache-2.0))
- [img2sdat](https://github.com/xpirt/img2sdat), licensed under the [MIT License](https://github.com/xpirt/img2sdat/blob/master/LICENSE)
- [platform_build](https://android.googlesource.com/platform/build/) (ext4_utils, f2fs_utils, signapk), licensed under the [Apache License 2.0](https://source.android.com/docs/setup/about/licenses)
