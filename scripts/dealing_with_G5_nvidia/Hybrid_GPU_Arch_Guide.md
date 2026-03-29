# Clean Arch Hybrid GPU Setup

This is the exact setup sequence I would use on a clean Arch install for a muxless Intel + NVIDIA laptop such as a Dell G5.

Target result:

- Intel iGPU drives the desktop
- NVIDIA dGPU works through PRIME offload when needed
- Plasma 6 runs on Wayland
- External outputs wired to NVIDIA still work through the normal driver stack

This guide assumes:

- Arch is already installed and boots successfully
- You are using the standard `linux` kernel unless noted otherwise
- You want the proprietary NVIDIA driver, not the `.run` installer
- Your NVIDIA GPU is Turing or newer, but on a Turing laptop you still want `nvidia`, not `nvidia-open`

## 1. Firmware / BIOS

Before touching Arch, check firmware settings:

- Set storage mode to `AHCI`, not RAID
- Leave hybrid graphics / Optimus enabled
- Disable Secure Boot unless you are already managing signed kernel modules

If firmware has a setting that fully disables the NVIDIA GPU, do not use it.

## 2. Base package install

On a fresh system, install the desktop-side Intel stack, the proprietary NVIDIA stack, and a few validation tools:

```bash
sudo pacman -Syu
sudo pacman -S --needed \
  mesa lib32-mesa mesa-utils vulkan-tools \
  vulkan-intel lib32-vulkan-intel \
  nvidia nvidia-utils lib32-nvidia-utils \
  nvidia-prime \
  plasma-meta sddm
```

Notes:

- If you use `linux-lts`, replace `nvidia` with `nvidia-lts`
- If you use a custom kernel, use `nvidia-dkms` and install matching kernel headers
- Do not install NVIDIA drivers from NVIDIA's `.run` installer
- Do not install `xf86-video-intel`
- On Turing laptops, avoid `nvidia-open` because it still has notebook power-management drawbacks

Enable the display manager:

```bash
sudo systemctl enable sddm
```

If your network is not already managed, also enable your network service separately.

## 3. Make NVIDIA DRM explicit

Current Arch `nvidia-utils` enables `modeset` and `fbdev` by default, but on a clean install I still make them explicit in the boot loader so the setup is obvious and reproducible.

Add these kernel parameters once, and only once:

```text
nvidia_drm.modeset=1 nvidia_drm.fbdev=1
```

### systemd-boot example

Edit your loader entry:

```bash
sudoedit /boot/loader/entries/*.conf
```

Example:

```text
options root=UUID=... rw nvidia_drm.modeset=1 nvidia_drm.fbdev=1
```

Afterward, make sure you do not have duplicate copies of either parameter.

## 4. Load NVIDIA modules early

This is the part that prevents a lot of display-manager and Wayland startup weirdness on hybrid laptops.

Edit `mkinitcpio`:

```bash
sudoedit /etc/mkinitcpio.conf
```

Set:

```text
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

Then rebuild:

```bash
sudo mkinitcpio -P
```

## 5. Add the pacman hook

If you use the packaged `nvidia` driver instead of `nvidia-dkms`, regenerate initramfs automatically on NVIDIA updates.

Create:

```bash
sudo mkdir -p /etc/pacman.d/hooks
sudoedit /etc/pacman.d/hooks/nvidia.hook
```

Use:

```ini
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux

[Action]
Description=Updating NVIDIA module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'
```

If you use `linux-lts`, change `Target=linux` to `Target=linux-lts`.

If you use `nvidia-dkms`, skip this section.

## 6. Keep Xorg overrides out of the way

For a clean Wayland-first setup, do not create old Optimus/Xorg snippets unless you are fixing a specific X11 problem.

These files should not exist:

```bash
sudo rm -f /etc/X11/xorg.conf
sudo rm -f /etc/X11/xorg.conf.d/10-nvidia-offload.conf
sudo rm -f /etc/X11/xorg.conf.d/10-nvidia-outputclass.conf
sudo rm -f /etc/X11/xorg.conf.d/20-intel.conf
```

Also do not install Bumblebee or `optimus-manager` for this setup.

## 7. Reboot and log into Plasma Wayland

Reboot:

```bash
sudo reboot
```

At SDDM, choose `Plasma (Wayland)`.

Plasma 6 is Wayland-first on current Arch. Treat X11 as fallback only.

## 8. Verify the working state

After login, check the session type:

```bash
echo $XDG_SESSION_TYPE
```

Expected:

```text
wayland
```

Check that the boot parameters are present once:

```bash
cat /proc/cmdline
```

Check NVIDIA DRM modeset:

```bash
cat /sys/module/nvidia_drm/parameters/modeset
```

Expected:

```text
Y
```

Check `fbdev` too:

```bash
cat /sys/module/nvidia_drm/parameters/fbdev
```

Expected:

```text
Y
```

Check the driver is alive:

```bash
nvidia-smi
```

Check PRIME offload:

```bash
prime-run glxinfo -B | grep "OpenGL renderer"
```

Expected result: the renderer line should name the NVIDIA GPU.

Check the default desktop renderer:

```bash
glxinfo -B | grep "OpenGL renderer"
```

Expected result: the renderer line should name the Intel/Mesa path for the regular desktop.

## 9. Normal usage

For apps that should use the NVIDIA GPU:

```bash
prime-run appname
```

Examples:

```bash
prime-run steam
prime-run mangohud %command%
prime-run blender
```

For normal desktop work, just launch applications normally and let Intel handle the session.

## 10. If Wayland is unstable

Do these checks before changing strategy:

```bash
journalctl -b 0 --grep "nvidia\\|kwin\\|drm\\|xwayland"
```

```bash
pacman -Q nvidia nvidia-utils linux
```

```bash
journalctl -b 0 --priority=3
```

If you still get freezes or app-open hangs, test one controlled X11 fallback:

```bash
sudo pacman -S --needed plasma-x11-session
```

Log out, choose `Plasma (X11)`, and test again.

If X11 is stable while Wayland is not, the base NVIDIA install is likely fine and the remaining issue is in the Wayland/KWin/Xwayland path.

Do not start adding random Xorg snippets unless you have a specific X11 symptom to solve.

## 11. What not to do

Avoid these common mistakes:

- Do not use the NVIDIA `.run` installer
- Do not install `xf86-video-intel`
- Do not stack multiple old Optimus guides together
- Do not duplicate `nvidia_drm.modeset=1` or `nvidia_drm.fbdev=1` in the boot entry
- Do not switch to `nvidia-open` on a Turing notebook unless you are explicitly testing it

## 12. Minimal checklist

If you want the short version, these are the required steps:

1. Install `mesa`, `vulkan-intel`, `nvidia`, `nvidia-utils`, `lib32-nvidia-utils`, `nvidia-prime`, `plasma-meta`, and `sddm`
2. Enable `sddm`
3. Add `nvidia_drm.modeset=1 nvidia_drm.fbdev=1` to the kernel command line
4. Set `MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)` in `/etc/mkinitcpio.conf`
5. Run `sudo mkinitcpio -P`
6. Remove stale `/etc/X11` override files
7. Reboot
8. Log into `Plasma (Wayland)`
9. Verify `nvidia-smi` works and `prime-run glxinfo -B` shows the NVIDIA renderer

## 13. Sources checked

- ArchWiki: NVIDIA
- ArchWiki: NVIDIA Optimus
- ArchWiki: KDE

Current ArchWiki guidance used here reflects:

- `nvidia-utils` enabling `modeset` by default on modern Arch
- Plasma 6 using Wayland as the preferred session
- PRIME render offload being the supported NVIDIA hybrid path
