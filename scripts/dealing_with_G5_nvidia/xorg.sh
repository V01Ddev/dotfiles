#!/bin/bash
set -e

echo "[1/8] Removing old NVIDIA/Optimus configs..."
sudo pacman -Rns --noconfirm bumblebee optimus-manager optimus-manager-qt nvidia-utils nvidia-dkms nvidia nvidia-settings nvidia-prime nouveau xf86-video-nouveau || true

echo "[2/8] Reinstalling Intel drivers..."
sudo pacman -S --needed --noconfirm mesa lib32-mesa xf86-video-intel

echo "[3/8] Cleaning leftover configs..."
sudo rm -f /etc/X11/xorg.conf
sudo rm -f /etc/X11/xorg.conf.d/*.conf
sudo rm -f /etc/modprobe.d/*.conf

echo "[4/8] Installing NVIDIA stack..."
sudo pacman -S --needed --noconfirm nvidia nvidia-utils nvidia-prime nvidia-settings lib32-nvidia-utils

echo "[5/8] Enabling NVIDIA DRM modeset (systemd-boot)..."
BOOT_ENTRY=$(ls /boot/loader/entries/*.conf | head -n 1)
sudo sed -i 's/^options.*/& nvidia-drm.modeset=1/' "$BOOT_ENTRY"
echo "Updated boot entry: $BOOT_ENTRY"

echo "[6/8] Creating CORRECT hybrid GPU configs (Intel = primary, NVIDIA = offload only)..."

# Intel drives internal display (eDP)
sudo tee /etc/X11/xorg.conf.d/20-intel.conf > /dev/null << "EOF"
Section "Device"
    Identifier  "Intel Graphics"
    Driver      "intel"
    Option      "TearFree" "true"
EndSection
EOF

# NVIDIA offload, NOT primary (so laptop screen works)
sudo tee /etc/X11/xorg.conf.d/10-nvidia-offload.conf > /dev/null << "EOF"
Section "Device"
    Identifier "NVIDIA Card"
    Driver "nvidia"
    BusID "PCI:1:0:0"
    Option "AllowEmptyInitialConfiguration"
    Option "IgnoreDisplayDevices" "CRT"
EndSection
EOF

echo "[7/8] Regenerating initramfs..."
sudo mkinitcpio -P

echo "[8/8] Done! Reboot to apply all changes."
echo ""
echo "After reboot test NVIDIA offload with:"
echo "  prime-run glxinfo | grep \"OpenGL renderer\""
