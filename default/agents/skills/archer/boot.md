# Boot Stack (Archer)

Archer mirrors Omarchy's Limine + LUKS + Plymouth + Btrfs stack. No ISO — manual archinstall with LUKS + Btrfs (`@`, `@home`, `@var`, `@snapshots`) then `setup.sh`.

```
ESP /boot (vfat, 2G)  →  /boot/limine.conf (flat, NOT /boot/limine/limine.conf)
                      →  /boot/EFI/limine/limine_x64.efi (via limine-install)
                      →  /boot/EFI/Linux/archer_linux.efi (UKI, via limine-mkinitcpio-hook)
                      →  /boot/limine.png (wallpaper, stretched)
```

- **Limine**: `install/login/limine.sh` — installs `limine` + `limine-mkinitcpio-hook` (AUR), writes `/etc/kernel/cmdline` (LUKS: `cryptdevice=PARTUUID=…:root root=/dev/mapper/root … rootflags=subvol=@`), writes `/etc/limine-entry-tool.d/archer-*.conf` (KERNEL_CMDLINE quiet/splash/loglevel, UKI `archer`, fallback, BOOT_ORDER, snapshots), deploys `default/limine/limine.conf` header (`#timeout: 3`, `default_entry: 2`, `hash_mismatch_panic: no`, branding `Archer #74a86a`), runs `limine-install` + `limine-entry-tool`.
- **Plymouth**: `install/login/plymouth.sh` — installs theme `default/plymouth/archer/` → `/usr/share/plymouth/themes/archer/`, writes `/etc/plymouth/plymouthd.conf` (`Theme=archer`), writes `/etc/mkinitcpio.conf.d/archer_hooks.conf` (`HOOKS=(base udev plymouth keyboard … block encrypt filesystems … btrfs-overlayfs)` + NVIDIA kms guard + vconsole bundling), rebuilds via `limine-mkinitcpio`.
- **mkinitcpio**: never sed the main `mkinitcpio.conf`; use drop-ins in `/etc/mkinitcpio.conf.d/`.
- **Update**: `update.sh` re-runs `limine-entry-tool` + `limine-mkinitcpio` (guarded).

Validate: `findmnt /boot`, `cat /boot/limine.conf`, `cat /etc/kernel/cmdline`, `ls /etc/limine-entry-tool.d/`, `cat /etc/mkinitcpio.conf.d/archer_hooks.conf`.
