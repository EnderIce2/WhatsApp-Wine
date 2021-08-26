![GitHub](https://img.shields.io/github/license/EnderIce2/WhatsApp-Wine?style=for-the-badge)

# WhatsApp-Wine

Out Of The Box [WhatsApp](https://www.whatsapp.com/) Installer for Linux using [Wine](https://winehq.org/)

---

### Why?
Simple. My friends want to try Linux for first time and it's too hard to understand Wine and manually configure everything. So, I made this simple script to help everyone that have trouble installing WhatsApp on Linux without any port or from your web browser. 

---

### 📥 Downloading and installing everything
All you have to do is to paste the following into your terminal:

```bash
cd /tmp && git clone https://github.com/EnderIce2/WhatsApp-Wine/whatsapp-wine.sh && chmod +x ./whatsapp-wine.sh && ./whatsapp-wine.sh
```

ℹ️ Make sure you have the latest version of [Wine](https://wiki.winehq.org/) (minimum 6.15)

### 📖 Installing Prerequisites
- Ubuntu
  - [Wine Stable](https://wiki.winehq.org/Ubuntu)
  - Packages (`sudo apt install p7zip-rar winetricks imagemagick`)
- Fedora
  - [Wine Stable](https://wiki.winehq.org/Fedora)
  - Packages (`sudo dnf install p7zip winetricks imagemagick`)
- OpenSUSE
  - Packages (`sudo zypper install wine p7zip-full winetricks imagemagick`)

ℹ️ Winetricks should be installed automatically with Wine.

---

### 🖊️Note

- I'm not sure if on other Linux distributions works
- I tested this script on Ubuntu 20.04, Fedora 32 and OpenSUSE Leap 15.2
- I made it to work the best on Ubuntu 20.04, in the future maybe I will make it for other distributions.
