# UN1CA AIOS for Samsung Galaxy S8 (dreamlte)

UN1CA (/ˈu.ni.ka/) AIOS is an optimized, feature-rich custom firmware port tailored specifically for the Samsung Galaxy S8 (Exynos 8895 - dreamlte). Built on top of modern One UI bases and backported system modules, UN1CA AIOS transforms legacy flagship hardware by integrating Samsung's latest Galaxy AI ecosystem, visual enhancements, and system-level performance optimizations into a smooth, everyday driver.

## 🚀 Community & Support
* Discussions & News: [Project Hub]
* Support Group: 💬 [Telegram Group]
* Issue Tracker: [GitHub Issues]

## 📱 Device Target Specifications

| Component | Target Device Details |
|---|---|
| Device Model | Samsung Galaxy S8 (dreamlte) |
| Chipset | Exynos 8895 Octa (4x2.3 GHz Mongoose M2 & 4x1.7 GHz Cortex-A53) |
| GPU | Mali-G71 MP20 (Vulkan 1.2 / OpenGL ES 3.2 support) |
| System Base | Ported Galaxy S22 One UI Base with Galaxy S25 / AI Stack backports |
| File System | EROFS read-only system partitions with dynamic repartitioning layout |

## ✨ System Features & AI Capabilities

### Core System Features
* **Modernized System Base:** Built on a stable Galaxy S22 firmware foundation with full EROFS file system support for faster app launch times and reduced memory footprint.
* **S25 Ecosystem Porting:** Includes official Galaxy S25 system wallpapers, notification sounds, ringtones, and UI iconography.
* **High-End UI & Visuals:**
  * Full native/live blur support across modern Samsung UI overlays.
  * Seamless Always-On Display (AOD) to lock screen clock transitions.
  * Adaptive Color Tone and simulated Adaptive Refresh Rate framework.
  * Extra Brightness toggle enabled for outdoor visibility.
* **Camera & Media Enhancements:**
  * System-wide Camera Privacy Toggle integration.
  * Picture Remaster, Object Eraser, Shadow Eraser, and Reflection Eraser integrated into Samsung Gallery.
  * Smart Image Clipper support for quick object extraction.
  * Custom FlipFont engine enabled out-of-the-box.
* **Power User & Privacy Controls:**
  * Multi-User account support enabled.
  * Samsung DeX support fully operational via DisplayPort USB-C and wireless display mode.
  * Dual Messenger unlocked for all third-party applications.
  * Auto PIN confirmation (instantly unlocks upon typing 4-digit PIN).
  * Outdoor mode display toggle.

## 🤖 Galaxy AI Suite Integrations

The firmware embeds a stripped, high-efficiency port of Samsung’s Galaxy AI framework, optimized to run smoothly within the hardware limits of the Exynos 8895:

* **Audio Eraser:** Remove unwanted background noise from voice recordings and videos.
* **Browsing Assist:** AI-powered article summarization and translation inside Samsung Internet.
* **Call Assist:** Live translation and text-to-speech transcription during phone calls.
* **Drawing Assist:** Transform rough sketches into refined illustrations.
* **Interpreter:** Real-time dual-language conversation translation with split-screen view.
* **Note Assist:** Auto-formatting, summarization, spellcheck, and translation inside Samsung Notes.
* **Now Brief:** Contextual daily summaries, weather updates, and schedule digests.
* **Photo Assist:** Generative photo editing, object relocation, and background expansion.
* **Semantic Search:** Deep natural-language query searching inside Gallery and System Apps.
* **Transcript Assist:** Speaker diarization and automatic text transcripts for Voice Recorder.
* **Writing Assist:** Tone adjustment, grammar corrections, and instant message translation.

## 🛠️ UN1CA-Exclusive Features & Tweak Center

* **Integrated OTA Updates App:** Dedicated update engine based on LineageOS updater architecture for seamless incremental updates.
* **Vulkan Renderer Engine Toggle:** Force system UI rendering through Vulkan API for smoother GPU frame delivery on Mali-G71.
* **Live Blur Control:** Toggle native blur effects on or off to maximize performance or save battery.
* **One UI Home Animation Selector:** Adjust launcher frame transitions and gesture responsiveness.
* **Key Attestation & Security Options:**
  * Integrated TrickyStore key attestation spoofing options (requires user-provided valid keybox).
  * Play Integrity Fix built-in to pass Basic and Device integrity checks out-of-the-box.
  * Integrated BluetoothLibraryPatcher to prevent pairing loss across reboots.
  * Integrated KnoxPatch to bypass Knox security checks for Samsung Health, Secure Folder, and Pass.
* **App & Permission Controls:**
  * Native app hiding via Hide My Applist framework integration.
  * Developer Options visibility toggle.
  * App Downgrade toggle (allows installing older APK versions over newer ones).
  * Bypass targetSdk restrictions (allows installing legacy apps targeting older Android APIs).
  * Secure Screenshot Toggle (enables screenshots in restricted apps/banking applications).
  * Screenshot & Screen Recording detection bypass toggle.
* **Media & Gaming Optimizations:**
  * Unlimited original-quality backup storage spoofing for Google Photos.
  * Game FPS unlock toggle for mobile titles.
* **CSC Extra Features Unlocked:**
  * Native Stock Call Recording (region independent).
  * Hiya caller ID & spam protection support.
  * Network speed indicator in the status bar.
  * AltZLife secure dual-app switching mode.

## 🔧 Galaxy S8 (dreamlte) Specific Optimizations

* **Dynamic Repartitioning Support:** Automated build script includes dynamic repartitioning patches to expand the /system partition using vendor space, allowing modern One UI base installs without partition overflow.
* **Exynos 8895 Kernel Adjustments:**
  * Built with custom kernel optimizations targeting the 10nm LPP Exynos node.
  * Advanced zRAM compression (LZ4/ZSTD) enabled to maintain multi-tasking headroom on 4GB LPDDR4x RAM.
  * Custom thermal throttle profiles to reduce overheating during AI-heavy workloads.
* **DisplayPort DeX Compatibility:** Full wired Samsung DeX desktop experience via USB-C to HDMI adapters (utilizing dreamlte native DisplayPort Alternate Mode).

## 📦 Build System & Automated Tooling

The UN1CA build pipeline operates via an automated workflow tailored for target Samsung boards:

* **Environment Setup:** Automatically compiles host dependencies (erofs-utils, apktool, android-tools, ext4_utils).
* **Firmware Extraction:** Downloads and unpacks official stock vendor firmware packages and port target bases.
* **Patch Execution:** Applies device-specific patches (dreamlte device tree, platform fixes, SELinux policies, and CSC tweaks).
* **AI & Feature Injection:** Strips obsolete system bloat and injects Galaxy AI modules, KnoxPatch, and custom APKs.
* **Image Generation:** Compresses images into EROFS system structures and outputs a TWRP-flashable ZIP archive.

## 📜 Licensing & Dependencies

UN1CA AIOS is licensed under the GNU General Public License v3.0 (GPL-3.0).

External tools and dependencies bundled or utilized within the build pipeline remain under their respective licenses:

* android-tools: Apache License 2.0
* apktool: Apache License 2.0
* erofs-utils: Dual licensed under GPL-2.0 and Apache-2.0
* img2sdat: MIT License
* platform_build (ext4_utils, f2fs_utils, signapk): Apache License 2.0

## 🙌 Credits & Acknowledgments

Special thanks to the developers, maintainers, and community members whose work makes this project possible:

* **ShaDisNX255** — For foundational work on NcX ROM and inspiration for One UI porting methodologies.
* **DavidArsene** — For assistance, testing, and system patch contributions.
* **paulowesll** — For continuous support, testing, and bug hunting.
* **Simon1511** — For device-specific patches, trees, and system fixes.
* **ananjaser1211** — For expert troubleshooting, kernel development support, and Exynos platform knowledge.
* **Fede2782** — For Exynos platform contributions and framework integration help.
* **iDrinkCoffee & RisenID** — For ongoing testing and feature feedback.
* **LineageOS Team** — For the open-source updater architecture and core components.
* **All Contributors, Testers, and Device Maintainers** — Thank you for keeping classic hardware alive! ❤️
