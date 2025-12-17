#!/bin/bash
set -e

echo "[1/5] Ensuring NVIDIA stack is installed..."
sudo pacman -S --needed --noconfirm nvidia nvidia-utils lib32-nvidia-utils nvidia-prime nvidia-settings

echo "[2/5] Enabling NVIDIA DRM Modeset (required for Wayland)..."
BOOT_ENTRY=$(ls /boot/loader/entries/*.conf | head -n 1)
sudo sed -i 's/^options.*/& nvidia-drm.modeset=1/' "$BOOT_ENTRY"
echo "Updated boot entry: $BOOT_ENTRY"

echo "[3/5] Removing all X11 config files that break Wayland..."
sudo rm -f /etc/X11/xorg.conf
sudo rm -f /etc/X11/xorg.conf.d/10-nvidia-offload.conf
sudo rm -f /etc/X11/xorg.conf.d/20-intel.conf

echo "[4/5] Regenerating initramfs..."
sudo mkinitcpio -P

echo "[5/5] Done! Reboot, then select 'Plasma (Wayland)' at login."
echo "Use 'nvidia-smi' and 'prime-run' to verify GPU usage."
