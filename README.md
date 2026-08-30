# 🦉 Owl (formerly LidAwake)

Owl is a lightweight, fully native macOS utility that lives in your menu bar and intelligently prevents your Mac from sleeping. Whether you need to keep your Mac awake while downloading large files, running long scripts, or using specific applications, Owl has you covered.

![Menu Bar Icon](assets/menubar.png)

## ✨ Features

- **Manual Override:** Quickly arm or disarm Owl straight from the menu bar or via the `Cmd + Shift + L` keyboard shortcut.
- **Smart App Automation:** Automatically keep your Mac awake when specific apps (like Xcode, Cursor, VS Code, or Terminal) are running, and let it sleep when they are closed.
- **Battery Safety Lock:** Owl actively monitors your battery. If your battery drops below a customizable threshold (e.g., 15%) while disconnected from power, Owl will instantly disarm itself to save your battery.
- **Native Notifications:** Get native macOS notifications when the state changes so you always know what's happening.
- **Feather-light:** Written purely in Swift with SwiftUI. No heavy Electron footprint.

## 🚀 Installation

*Note: Since Owl interacts with macOS's `pmset` power management tool, it requires a quick one-time passwordless sudo setup.*

1. Clone the repository:
   ```bash
   git clone https://github.com/repl-agastya-jha/Owl.git
   cd Owl
   ```
2. Build the app using the provided script:
   ```bash
   ./build.sh
   ```
3. Run the one-time `pmset` configuration (this command will also be printed by the build script):
   ```bash
   echo "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/pmset" | sudo tee /etc/sudoers.d/pmset-nopasswd > /dev/null
   ```
4. Drag `Owl.app` to your `/Applications` folder and launch it!

## ⚙️ How It Works

Owl uses macOS's native `pmset` utility under the hood to toggle the `SleepDisabled` flag. It features an intelligent run loop that checks system status every 10 seconds, ensuring your settings (like battery safety and app automation) are strictly enforced even if you walk away from your computer.

## 📸 Screenshots

*(To add more screenshots, drop them in the `assets/` directory!)*

---
*Created by [repl-agastya-jha](https://github.com/repl-agastya-jha)*
