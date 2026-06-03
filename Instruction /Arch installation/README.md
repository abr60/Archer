# Complete Arch Linux Installation Guide (EXT4 & Btrfs)

*Using* `*archinstall*` *with Manual Partitioning, Mounting, and Troubleshooting*

------

## 📌 Table of Contents

1. [Pre-Installation](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#1-pre-installation)
   - [Connect to the Internet](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#connect-to-the-internet)
   - [Initialize and Update the Keyring](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#initialize-and-update-the-keyring)
2. [Disk Partitioning](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#2-disk-partitioning)
   - [Identify the Disk](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#identify-the-disk)
   - [Partitioning with `cfdisk`](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#partitioning-with-cfdisk)
3. [Filesystem Setup](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#3-filesystem-setup)
   - [EXT4 Setup](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#ext4-setup)
   - [Btrfs Setup](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#btrfs-setup)
4. [Mounting Partitions](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#4-mounting-partitions)
   - [EXT4 Mounting](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#ext4-mounting)
   - [Btrfs Mounting](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#btrfs-mounting)
5. [Run `archinstall`](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#5-run-archinstall)
6. [Troubleshooting](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#6-troubleshooting)
   - [Unmounting Partitions](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#unmounting-partitions)
   - [Remounting Partitions](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#remounting-partitions)
   - [Common Issues](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#common-issues)
7. [Post-Installation](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#7-post-installation)
8. [Additional Resources](https://chat.mistral.ai/chat/a0513002-18c3-4be3-8bcc-832c51c4c9e2#8-additional-resources)

------

------

## 1. Pre-Installation

### Connect to the Internet

**Required for keyring updates and package downloads.**

#### Wired (Ethernet)

```bash
ip link set enp0s3 up    # Replace `enp0s3` with your interface
 dhcpcd enp0s3
 ping archlinux.org        # Verify connection
```

#### Wireless (Wi-Fi)

```bash
iwctl
device list                # Identify your wireless device (e.g., `wlan0`)
station wlan0 scan
station wlan0 get-networks # List available networks
station wlan0 connect <SSID>
exit
ping archlinux.org        # Verify connection
```

------

### Initialize and Update the Keyring

**Prevents package signature verification failures.**

```bash
pacman-key --init
pacman-key --populate
pacman -Sy archlinux-keyring
pacman-key --refresh-keys
```

------

------

## 2. Disk Partitioning

### Identify the Disk

```bash
lsblk
```

- Note your disk (e.g., `/dev/sda`, `/dev/nvme0n1`).

------

### Partitioning with `cfdisk`

```bash
cfdisk /dev/sdX  # Replace `sdX` with your disk
```

#### Recommended Partition Layout (UEFI)

| Partition | Type             | Size      | Notes                          |
| --------- | ---------------- | --------- | ------------------------------ |
| 1         | EFI System       | 512MB–1GB | For UEFI bootloader            |
| 2         | Linux Filesystem | Remaining | Root partition (EXT4 or Btrfs) |

- **For EFI Partition**: Select `EFI System` type.
- **For Root Partition**: Select `Linux Filesystem` type.
- **Write changes** and exit `cfdisk`.

------

------

## 3. Filesystem Setup

### EXT4 Setup

**Simple, reliable, and widely used.**

#### Format Partitions

```bash
# Format EFI partition (FAT32)
mkfs.fat -F32 /dev/sdX1

# Format root partition (EXT4)
mkfs.ext4 /dev/sdX2
```

------

### Btrfs Setup

**Advanced features: subvolumes, compression, snapshots.**

#### Format Partitions

```bash
# Format EFI partition (FAT32)
mkfs.fat -F32 /dev/sdX1

# Format root partition (Btrfs)
mkfs.btrfs /dev/sdX2
```

#### Create Btrfs Subvolumes

```bash
# Mount the Btrfs partition temporarily
mount /dev/sdX2 /mnt

# Create subvolumes
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@var
btrfs subvolume create /mnt/@snapshots

# Unmount the partition
umount /mnt
```

------

------

## 4. Mounting Partitions

### EXT4 Mounting

```bash
# Mount root partition
mount /dev/sdX2 /mnt

# Create and mount EFI partition
mkdir -p /mnt/boot
mount /dev/sdX1 /mnt/boot
```

------

### Btrfs Mounting

```bash
# Mount root subvolume (@)
mount -o compress=zstd,subvol=@ /dev/sdX2 /mnt

# Create directories for subvolumes
mkdir -p /mnt/{home,var,.snapshots}

# Mount subvolumes
mount -o compress=zstd,subvol=@home /dev/sdX2 /mnt/home
mount -o compress=zstd,subvol=@var /dev/sdX2 /mnt/var
mount -o compress=zstd,subvol=@snapshots /dev/sdX2 /mnt/.snapshots

# Mount EFI partition
mkdir -p /mnt/boot
mount /dev/sdX1 /mnt/boot
```

------

### Verify Mounts

```bash
lsblk
mount | grep /mnt
```

- Ensure all partitions/subvolumes are mounted correctly under `/mnt`.

------

------

## 5. Run `archinstall`

### Launch the Script

```bash
cd /  # Avoid "busy" errors
archinstall
```

### Disk Configuration

- Select: **"Use a pre-mounted configuration"**.
- Confirm `/mnt` is detected as the target.

### Configure System

- Select your **Desktop Environment**, **User Accounts**, and **Packages**.
- Proceed through the summary and **start the installation**.

------

------

## 6. Troubleshooting

### Unmounting Partitions

**Use this if you need to redo partitioning or fix mounting issues.**

```bash
# Unmount all partitions under /mnt
umount -R /mnt

# Verify no partitions are mounted
mount | grep /mnt
```

------

### Remounting Partitions

**For EXT4:**

```bash
# Mount root partition
mount /dev/sdX2 /mnt

# Mount EFI partition
mkdir -p /mnt/boot
mount /dev/sdX1 /mnt/boot
```

**For Btrfs:**

```bash
# Mount root subvolume
mount -o compress=zstd,subvol=@ /dev/sdX2 /mnt

# Create directories for subvolumes
mkdir -p /mnt/{home,var,.snapshots}

# Mount subvolumes
mount -o compress=zstd,subvol=@home /dev/sdX2 /mnt/home
mount -o compress=zstd,subvol=@var /dev/sdX2 /mnt/var
mount -o compress=zstd,subvol=@snapshots /dev/sdX2 /mnt/.snapshots

# Mount EFI partition
mkdir -p /mnt/boot
mount /dev/sdX1 /mnt/boot
```

------

### Common Issues

#### Issue: `archinstall` Complains About "Busy" or "Mounted" Partitions

- **Solution**: Ensure you are **not** in `/mnt` or any of its subdirectories.

  ```bash
  cd /
  ```

#### Issue: Partition Not Detected

- **Solution**: Verify the partition exists and is formatted:

  ```bash
  lsblk -f
  ```

#### Issue: Btrfs Subvolumes Not Mounting

- **Solution**: Ensure subvolumes exist and are mounted with the correct options:

  ```bash
  btrfs subvolume list /mnt
  mount | grep /mnt
  ```

#### Issue: Internet Connection Fails

- **Solution**: Retry connection or check interface:

  ```bash
  ip a
  ping archlinux.org
  ```

------

------

## 7. Post-Installation

### Reboot

```bash
umount -R /mnt
reboot
```

### Post-Install Steps

1. **Log in** to your new system.

2. **Enable NetworkManager** (if using Wi-Fi):

   ```bash
    systemctl enable --now NetworkManager
   ```

3. **Install additional packages** (e.g., drivers, utilities):

   ```bash
    pacman -S <package-name>
   ```

4. **Set up users and permissions** (if not done during installation).

------

------

## 8. Additional Resources

- [Arch Wiki: Installation Guide](https://wiki.archlinux.org/title/Installation_guide)
- [Arch Wiki: Btrfs](https://wiki.archlinux.org/title/Btrfs)
- [Arch Wiki: EXT4](https://wiki.archlinux.org/title/Ext4)
- [Arch Wiki: `archinstall`](https://wiki.archlinux.org/title/Archinstall)
- [Btrfs Subvolume Guide](https://btrfs.wiki.kernel.org/index.php/Using_Btrfs_with_Multiple_Devices#Subvolumes)

------

------

## 🔹 Quick Reference: Commands Summary

### EXT4

| Step        | Command                                           |
| ----------- | ------------------------------------------------- |
| Format EFI  | `mkfs.fat -F32 /dev/sdX1`                         |
| Format Root | `mkfs.ext4 /dev/sdX2`                             |
| Mount Root  | `mount /dev/sdX2 /mnt`                            |
| Mount EFI   | `mkdir -p /mnt/boot && mount /dev/sdX1 /mnt/boot` |
| Unmount All | `umount -R /mnt`                                  |

### Btrfs

| Step              | Command                                                      |
| ----------------- | ------------------------------------------------------------ |
| Format EFI        | `mkfs.fat -F32 /dev/sdX1`                                    |
| Format Root       | `mkfs.btrfs /dev/sdX2`                                       |
| Create Subvolumes | `btrfs subvolume create /mnt/@{,@home,@var,@snapshots}`      |
| Mount Root        | `mount -o compress=zstd,subvol=@ /dev/sdX2 /mnt`             |
| Mount Subvolumes  | `mount -o compress=zstd,subvol=@home /dev/sdX2 /mnt/home` (repeat for others) |
| Mount EFI         | `mkdir -p /mnt/boot && mount /dev/sdX1 /mnt/boot`            |
| Unmount All       | `umount -R /mnt`                                             |

------

------

**💡 Pro Tips:**

- **Btrfs Compression**: Use `compress=zstd` for better performance and space savings.
- **Snapshots**: Use `btrfs subvolume snapshot /mnt/@ /mnt/@snapshots/pre-install` for system rollbacks.
- **Backup**: Always back up important data before partitioning.
- **Double-Check**: Use `lsblk` and `mount` to verify partitions before proceeding.