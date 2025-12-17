
# Arch Linux Hybrid GPU Setup (Intel Primary + NVIDIA Offload)

This document explains all steps taken to set up an Intel + NVIDIA hybrid GPU laptop
(such as the Dell G5 with a GTX 1660 Ti) on **Arch Linux** using **systemd-boot**.

It includes:
- A stable **X11 configuration** (Intel drives laptop screen, NVIDIA used for offload)
- A **Wayland-ready configuration** for KDE Plasma 6
- Notes for troubleshooting and GPU verification

---

# 1. CLEANING OLD CONFIGURATION

## Remove all old NVIDIA / Optimus / Bumblebee / nouveau configurations:
```
sudo pacman -Rns bumblebee optimus-manager optimus-manager-qt nvidia-utils nvidia-dkms nvidia nvidia-settings nvidia-prime nouveau xf86-video-nouveau
```

## Reinstall Intel drivers:
```
sudo pacman -S --needed mesa xf86-video-intel lib32-mesa
```

## Clean leftover config files:
```
sudo rm -f /etc/X11/xorg.conf
sudo rm -f /etc/X11/xorg.conf.d/*.conf
sudo rm -f /etc/modprobe.d/*.conf
```

## Regenerate initramfs:
```
sudo mkinitcpio -P
```

Reboot once:
```
sudo reboot
```

---

# 2. INSTALL NVIDIA DRIVERS

```
sudo pacman -S nvidia nvidia-utils nvidia-prime nvidia-settings lib32-nvidia-utils
```

---

# 3. ENABLE MODSETTING FOR NVIDIA (SYSTEMD-BOOT)

Edit your boot entry:

```
sudo nano /boot/loader/entries/arch.conf
```

Append:
```
nvidia-drm.modeset=1
```

Example:
```
options root=UUID=xxxx rw quiet loglevel=3 nvidia-drm.modeset=1
```

---

# 4. X11 CONFIGURATION (INTEL = PRIMARY, NVIDIA = OFFLOAD ONLY)

## Intel drives laptop panel:
```
/etc/X11/xorg.conf.d/20-intel.conf
```
```
Section "Device"
    Identifier  "Intel Graphics"
    Driver      "intel"
    Option      "TearFree" "true"
EndSection
```

## NVIDIA offloads workloads:
```
/etc/X11/xorg.conf.d/10-nvidia-offload.conf
```
```
Section "Device"
    Identifier "NVIDIA Card"
    Driver "nvidia"
    BusID "PCI:1:0:0"
    Option "AllowEmptyInitialConfiguration"
    Option "IgnoreDisplayDevices" "CRT"
EndSection
```

Regenerate initramfs:
```
sudo mkinitcpio -P
```

Reboot:
```
sudo reboot
```

---

# 5. VERIFY GPU SETUP

## NVIDIA offload:
```
prime-run glxinfo | grep "OpenGL renderer"
```

Expected:
```
GeForce GTX 1660 Ti
```

## Intel running the desktop:
```
glxinfo | grep "OpenGL renderer"
```

Expected:
```
Mesa Intel UHD Graphics
```

---

# 6. WAYLAND CONFIGURATION FOR KDE PLASMA 6

Wayland uses KMS + EGLStreams (supported by NVIDIA).

### REQUIREMENTS:
- `nvidia`
- `nvidia-utils`
- `nvidia-dkms` (optional)
- `nvidia-drm.modeset=1` MUST be enabled
- Plasma 6 or newer

### ENABLE WAYLAND SUPPORT

Ensure this line exists:
```
options ... nvidia-drm.modeset=1
```

No Xorg `.conf` files are needed for Wayland.  
Wayland ignores them by design **except** if they break the session.

If Wayland fails to load:
- Remove `/etc/X11/xorg.conf.d/20-intel.conf`
- Remove `/etc/X11/xorg.conf.d/10-nvidia-offload.conf`

Wayland handles hybrid GPUs automatically using KWin.

---

# 7. VERIFY WAYLAND GPU USAGE

## Check Wayland session:
```
echo $XDG_SESSION_TYPE
```

Should output:
```
wayland
```

## Check NVIDIA availability:
```
nvidia-smi
```

## Test offloading under Wayland:
```
prime-run glxinfo | grep "OpenGL renderer"
```

---

# 8. EXTERNAL MONITORS UNDER WAYLAND

Your Dell G5 (1660 Ti) uses:
- Internal (eDP) → Intel iGPU  
- HDMI/DP → NVIDIA GPU  

Wayland + NVIDIA Plasma 6 correctly proxies external monitors through KWin.

If external monitor fails:
```
sudo systemctl restart sddm
```
Or log out → choose **Plasma (Wayland)** again.

---

# 9. TROUBLESHOOTING QUICK NOTES

### Black internal screen → Intel not primary  
Delete:
```
/etc/X11/xorg.conf.d/*nvidia*
```

### Wayland session crashes → NVIDIA driver mismatch  
Reinstall:
```
sudo pacman -S nvidia nvidia-utils
```

### KDE stutter on X11 → enable tear-free on Intel  
Set in `/etc/X11/xorg.conf.d/20-intel.conf`:
```
Option "TearFree" "true"
```

---

# 10. FILES TO REMEMBER

| Purpose | Path |
|--------|------|
| systemd-boot entry | /boot/loader/entries/arch.conf |
| Intel config | /etc/X11/xorg.conf.d/20-intel.conf |
| NVIDIA offload config | /etc/X11/xorg.conf.d/10-nvidia-offload.conf |
| mkinitcpio | /etc/mkinitcpio.conf |

---

# 11. FINAL NOTES

- X11 = most reliable on NVIDIA hybrid laptops  
- Wayland = works if `nvidia-drm.modeset=1` and Plasma 6+  
- External monitor → always routed through NVIDIA  
- Internal laptop display → always routed through Intel  

You now have BOTH configurations documented for future resets.

