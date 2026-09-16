<h1 align="center">
  <img loading="lazy" src="readme-res/banner.png"/>
</h1>
<p align="center">
  <a href="https://github.com/salvogiangri/UN1CA/blob/sixteen/LICENSE"><img loading="lazy" src="https://img.shields.io/github/license/salvogiangri/UN1CA?style=for-the-badge&logo=github"/></a>
  <a href="https://github.com/salvogiangri/UN1CA/commits/sixteen"><img loading="lazy" src="https://img.shields.io/github/last-commit/salvogiangri/UN1CA/sixteen?style=for-the-badge"/></a>
  <a href="https://github.com/salvogiangri/UN1CA/stargazers"><img loading="lazy" src="https://img.shields.io/github/stars/salvogiangri/UN1CA?style=for-the-badge"/></a>
  <a href="https://github.com/salvogiangri/UN1CA/actions/workflows/ci.yml"><img loading="lazy" src="https://img.shields.io/github/actions/workflow/status/salvogiangri/UN1CA/ci.yml?style=for-the-badge"/></a>
  <a href="https://crowdin.com/project/UN1CA"><img loading="lazy" src="https://img.shields.io/badge/Crowdin-263238?style=for-the-badge&logo=crowdin"/></a>
</p>
<p align="center">UN1CA <i>(/ˈu.ni.ka/)</i> is a work-in-progress custom firmware for Samsung Galaxy devices.</p>

<p align="center">
  <a href="https://github.com/salvogiangri/UN1CA/discussions">🚀 Discussions</a>
  •
  <a href="https://t.me/unicarom">💬 Telegram</a>
</p>

# What is UN1CA?
UN1CA is a work-in-progress custom firmware for Samsung Galaxy devices, designed to provide a refined, optimized and more rich One UI experience.
It is based on the latest and greatest iteration of Samsung's UX and it integrates numerous improvements, optimizations and exclusive features.

The UN1CA build system automatically builds the required tools, downloads and extracts firmware components, applies the required patches and generates a flashable zip for the target device.

The goal is to deliver a fast, smooth and modern UX while offering additional tools, modifications and system‑level enhancements tailored for power users.

Any form of contribution, suggestions, bug report or feature request for the project will be welcome.

# Features
### Core features:
- Based on the latest stable Galaxy S22 firmware
- EROFS powered
- Galaxy S25 wallpapers/sounds included
- Galaxy AI support
  - Audio eraser
  - Browsing assist
  - Call assist
  - Drawing assist
  - Interpreter
  - Note assist
  - Now brief
  - Photo assist
  - Semantic search
  - Transcript assist
  - Writing assist
- High end animations
- Native/live blur support
- AOD clock transition support
- Adaptive color tone support
- Adaptive refresh rate support
- Extra brightness support
- Picture remaster support
- Object, shadow and reflection eraser support
- Image clipper support
- Multi user support
- Samsung DeX support*
- Camera privacy toggle support
- Debloated from useless system services/additional apps
- Dual Messenger available for all apps
- Custom FlipFont fonts support
- Outdoor mode support
- Auto PIN confirm with 4 digits
- [BluetoothLibraryPatcher](https://github.com/3arthur6/BluetoothLibraryPatcher) integrated
- [KnoxPatch](https://github.com/salvogiangri/KnoxPatch) integrated
- Extra CSC features enabled (Call recording, Hiya, Network speed in status bar, AltZLife)

\* DeX via HDMI not available for devices without USB-C DP support

### UN1CA-exclusive features:
- Integrated OTA updates app
- Native/live blur toggle
- One UI Home animations option
- Vulkan renderer toggle
- Key attestation spoof ([TrickyStore](https://github.com/5ec1cff/TrickyStore)) options*
- Play Integrity Fix integrated
- Ability to hide installed apps ([Hide My Applist](https://github.com/Dr-TSNG/Hide-My-Applist))
- Ability to hide developer options
- Allow app downgrade toggle
- Allow installing apps with old targetSdk toggle
- Allow secure screenshot toggle
- Screenshot/screen recording detection toggle
- Unlimited backup storage on Google Photos
- Games FPS unlock toggle

### Maxregner v2 system (rebuilt):
The Maxregner layer has been completely rebuilt to a v2 design language and architecture.

- **Maxregner UI v2 design system** — a tonal, wallpaper‑driven semantic color system (light + dark, full surface‑container set), a unified shape scale (none → xxl + full), an elevation level system, glass blur radii, and a motion token set with standard / emphasized / overshoot easings. Ships as an overlay resource package plus a JSON token file at `/system/etc/maxregner/tokens.json`.
  - Dynamic tonal theme — derive the whole palette from the wallpaper
  - Glass surfaces — render panels with translucent glass blur
  - Overshoot motion — components settle with a light overshoot spring
- **Maxregner Orb v2 navigation** — replaces 3‑button nav and gestures with a single glassmorphic adaptive floating orb (recoded).
  - Radial menu (long‑hold) — Back / Home / Recents / Notifications / Screenshot / Assistant
  - Magnetic docking — snap to bottom/left/right edge dock zones (start/center/end slots)
  - Split‑screen pinch gestures — pinch to enter, spread to exit split‑screen
  - Contextual morphing — typing → back glyph, recents → recents glyph
  - Idle "breath" animation that fades on interaction
  - Adjustable gesture sensitivity (Gentle / Standard / Firm)
- **Maxregner Sound Scheme v2** — layered spatial sound set (UI effects / navigation orb / system feedback) plus secondary notification, ringtone and alarm variants. Ships the full `ro.config.*` mapping plus per‑effect props.
- **Maxregner Extras v2** — Maxregner Sans font (variable weight 400–800), glassmorphic AOD/lockscreen Orb clock, launcher gestures routed through the Orb (swipe‑up/left/right, long‑press home), and advanced system feature flags (glass surfaces, overshoot motion, rounded corners, smooth scroll).
- **Maxregner Battery Intelligence** — adaptive charging beyond One UI:
  - Learned usage‑pattern charge curves (adaptive charge)
  - Thermal‑aware charge caps (limit current when the cell exceeds a threshold)
  - Idle discharge hold (hold the pack in a 40–60% band overnight instead of sitting at 100%)
  - User‑tunable charge ceiling
- **Maxregner Privacy Guard** — system‑wide privacy hardening beyond One UI:
  - Clipboard read protection (block background clipboard reads)
  - Clipboard auto‑clear after a timeout
  - Sensor gate (deny sensors to apps that do not need them)
  - Per‑app network audit log
  - Hide network state (strip per‑app NET capability disclosure)
- **Maxregner settings panel** in Settings → UN1CA → Maxregner to toggle and tune each subsystem (nav, radial menu, split gestures, docking, breath, sensitivity, sound, UI, dynamic theme, glass, overshoot, AOD).

\* Requires a valid keybox

# Build system (rebuilt)
The build pipeline (`scripts/make_rom.sh`) was rebuilt into a clear, staged flow. Each stage is a guarded, logged, abort‑on‑failure block:

1. Firmware acquisition — download + extract (only if needed)
2. Work directory creation
3. Patch layers — platform → device → ROM
4. Mod layers — ROM mods (incl. all Maxregner v2 subsystems)
5. APK/JAR rebuild
6. OS partition images
7. Target‑files zip + flashable zip

Run with `source buildenv.sh <target>` then `unica make_rom [-f|-x|-z]`.

# Licensing
This project is licensed under the terms of the [GNU General Public License v3.0](LICENSE). External dependencies might be distributed under a different license, such as:
- [android-tools](https://github.com/nmeum/android-tools), licensed under the [Apache License 2.0](https://github.com/nmeum/android-tools/blob/master/LICENSE)
- [apktool](https://github.com/iBotPeaches/Apktool), licensed under the [Apache License 2.0](https://github.com/iBotPeaches/Apktool/blob/master/LICENSE.md)
- [erofs-utils](https://github.com/sekaiacg/erofs-utils/), dual license ([GPL-2.0](https://github.com/sekaiacg/erofs-utils/blob/dev/LICENSES/GPL-2.0), [Apache-2.0](https://github.com/sekaiacg/erofs-utils/blob/dev/LICENSES/Apache-2.0))
- [img2sdat](https://github.com/xpirt/img2sdat), licensed under the [MIT License](https://github.com/xpirt/img2sdat/blob/master/LICENSE)
- [platform_build](https://android.googlesource.com/platform/build/) (ext4_utils, f2fs_utils, signapk), licensed under the [Apache License 2.0](https://source.android.com/docs/setup/about/licenses)

# Contributors
<a href="https://github.com/salvogiangri/UN1CA/graphs/contributors"><img loading="lazy" src="https://contrib.rocks/image?repo=salvogiangri/UN1CA"/></a>

# Credits
A special thanks goes to the following for their invaluable contributions in no particular order:
- **[ShaDisNX255](https://github.com/ShaDisNX255)** for his help, time and for his [NcX ROM](https://github.com/ShaDisNX255/NcX_Stock) which inspired this project
- **[DavidArsene](https://github.com/DavidArsene)** for his help and time
- **[paulowesll](https://github.com/paulowesll)** for his help and support
- **[Simon1511](https://github.com/Simon1511)** for his support and some of the device-specific patches
- **[ananjaser1211](https://github.com/ananjaser1211)** for troubleshooting and his time
- **[Fede2782](https://github.com/Fede2782)** for his contributions and help with Exynos/MTK support
- **[iDrinkcoffee](https://github.com/iDrinkcoffee-TG)** and **[RisenID](https://github.com/RisenID)** for their support
- **[LineageOS Team](https://www.lineageos.org/)** for their original [OTA updater implementation](https://github.com/LineageOS/android_packages_apps_Updater)
- *All the UN1CA project forks, contributors, testers and users ❤️*
