# SeibuRescue - Encrypted Disk Unlocking Guide (BitLocker & LUKS)

This manual provides detailed instructions on how to unlock and mount encrypted drives—specifically **Windows BitLocker** and **Linux LUKS**—when booted into **SeibuRescue**.

---

## Table of Contents
1. [Overview & Prerequisites](#1-overview--prerequisites)
2. [Step 1: Identifying Encrypted Drives & Partitions](#2-step-1-identifying-encrypted-drives--partitions)
3. [Method 1: GUI Unlocking with GNOME Disks](#3-method-1-gui-unlocking-with-gnome-disks)
4. [Method 2: Unlocking BitLocker with `dislocker` (Recommended for Windows 10/11)](#4-method-2-unlocking-bitlocker-with-dislocker-recommended-for-windows-1011)
5. [Method 3: Unlocking BitLocker with `cryptsetup`](#5-method-3-unlocking-bitlocker-with-cryptsetup)
6. [Method 4: Unlocking Linux LUKS Partitions](#6-method-4-unlocking-linux-luks-partitions)
7. [Troubleshooting & Frequently Asked Questions](#7-troubleshooting--frequently-asked-questions)

---

## 1. Overview & Prerequisites

### Tools Included in SeibuRescue
SeibuRescue comes pre-packaged with all the necessary storage and cryptographic utilities:
- **GNOME Disks (`gnome-disks`)**: Graphical utility with desktop shortcut.
- **`dislocker`**: Specialized FUSE-based utility capable of decrypting BitLocker volumes using passwords, recovery keys, or `.bek` key files.
- **`cryptsetup`**: Kernel-level dm-crypt manager with native BitLocker (`--type bitlk`) and LUKS support.
- **`libblockdev-plugins-all`**: Backend libraries enabling disk encryption features.

### Recovery Information You Will Need
Before unlocking a Windows BitLocker drive, ensure you have one of the following:
- **BitLocker Recovery Key**: A 48-digit numerical key formatted in 8 groups of 6 digits (e.g., `123456-789012-345678-901234-567890-123456-789012-345678`).
  - *Tip: If linked to a Microsoft Account, retrieve it at [https://account.microsoft.com/devices/recoverykey](https://account.microsoft.com/devices/recoverykey)*.
- **User Passphrase / Password**: If configured instead of or in addition to TPM.
- **Recovery Key File (`.bek`)**: If saved to a USB flash drive.

---

## 2. Step 1: Identifying Encrypted Drives & Partitions

Open the terminal (from application menu or right-click Desktop -> Open Terminal) and run:

```bash
lsblk -f
```

Look for the partition marked with `BitLocker` or `crypto_LUKS` under the `FSTYPE` column:

```text
NAME        FSTYPE      LABEL       UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
nvme0n1                                                                                 
├─nvme0n1p1 vfat        SYSTEM      A1B2-C3D4                                           
├─nvme0n1p2                                                                             
├─nvme0n1p3 BitLocker   Windows     01234567-89AB-CDEF...                               
└─nvme0n1p4 ntfs        Recovery    FEDCBA98-7654-3210...                               
```

In this example, the encrypted partition is `/dev/nvme0n1p3`. Note down your specific device identifier (e.g., `/dev/nvme0n1p3` or `/dev/sda3`).

You can also inspect BitLocker metadata directly using:
```bash
sudo cryptsetup bitlkDump /dev/nvme0n1p3
```

---

## 3. Method 1: GUI Unlocking with GNOME Disks

1. Double-click the **Disks** icon on the desktop.
2. Select your drive from the left panel.
3. In the Volumes diagram, click on the encrypted partition (marked with a lock icon 🔒).
4. Click the **Unlock** button (lock/play icon below the volumes diagram).
5. Enter your passphrase or 48-digit recovery key and confirm.

> **Note on "Operation not supported"**:
> If Disks shows an error stating `Error unlocking /dev/...: Operation not supported`, this occurs because the Windows drive uses BitLocker features (such as "Encrypt-on-Write", modern conversion states, or TPM-only key protectors) that the GNOME Disks / `udisks2` graphical backend cannot automatically handle.
> **If you encounter this error, proceed to Method 2 (`dislocker`) below.**

---

## 4. Method 2: Unlocking BitLocker with `dislocker` (Recommended for Windows 10/11)

`dislocker` is the most compatible tool for unlocking BitLocker partitions on Linux, especially for modern Windows 10/11 systems.

### Step 2.1: Create Mount Points
Create directories for the decrypted virtual disk and the final filesystem mount:
```bash
sudo mkdir -p /media/bitlocker /media/windows
```

### Step 2.2: Decrypt with `dislocker`

**Option A: Using the 48-digit Recovery Key (Most Common)**
Replace `/dev/nvme0n1p3` with your partition and enter your 48-digit key:
```bash
sudo dislocker -v -V /dev/nvme0n1p3 -p123456-789012-345678-901234-567890-123456-789012-345678 -- /media/bitlocker
```

**Option B: Using a Password / Passphrase**
```bash
sudo dislocker -v -V /dev/nvme0n1p3 -u"YourSecretPassword" -- /media/bitlocker
```

**Option C: Using a `.bek` Key File**
```bash
sudo dislocker -v -V /dev/nvme0n1p3 -f /path/to/keyfile.bek -- /media/bitlocker
```

Once executed successfully, a virtual NTFS image file named `dislocker-file` will be created inside `/media/bitlocker/`.

### Step 2.3: Mount the Decrypted Filesystem
Mount the `dislocker-file` loopback device to access your files:

**Read-Write Mount:**
```bash
sudo mount -o loop,rw /media/bitlocker/dislocker-file /media/windows
```

**Read-Only Mount (Safer for data extraction / if Windows is in Hibernation):**
```bash
sudo mount -o loop,ro /media/bitlocker/dislocker-file /media/windows
```

Your decrypted Windows files and folders are now fully accessible under:
`/media/windows`

### Step 2.4: Safely Unmounting When Finished
When you are done accessing your files:
```bash
sudo umount /media/windows
sudo umount /media/bitlocker
```

---

## 5. Method 3: Unlocking BitLocker with `cryptsetup`

`cryptsetup` provides high-performance kernel-level mapping using dm-crypt.

### Step 3.1: Open the BitLocker Volume
Run the following command to unlock the volume and assign a device-mapper name (e.g., `bitlk_drive`):

```bash
sudo cryptsetup open --type bitlk /dev/nvme0n1p3 bitlk_drive
```

When prompted:
- Enter your password, OR
- Paste your 48-digit recovery key.

*(Optional: To pass a recovery key directly from a file, use: `sudo cryptsetup open --type bitlk --key-file /path/to/key.txt /dev/nvme0n1p3 bitlk_drive`)*

### Step 3.2: Mount the Mapped Volume
Once unlocked, the decrypted volume is exposed as `/dev/mapper/bitlk_drive`:

```bash
sudo mkdir -p /media/windows
sudo mount /dev/mapper/bitlk_drive /media/windows
```

### Step 3.3: Close and Lock When Finished
```bash
sudo umount /media/windows
sudo cryptsetup close bitlk_drive
```

---

## 6. Method 4: Unlocking Linux LUKS Partitions

If you have a Linux partition encrypted with LUKS:

### Via GUI (GNOME Disks):
Select the LUKS partition in **Disks**, click the **Unlock** icon, and enter your passphrase.

### Via Command Line:
```bash
# 1. Open the LUKS device
sudo cryptsetup luksOpen /dev/sda2 luks_drive

# 2. Mount the volume
sudo mkdir -p /media/linux_drive
sudo mount /dev/mapper/luks_drive /media/linux_drive

# 3. When finished, unmount and lock
sudo umount /media/linux_drive
sudo cryptsetup luksClose luks_drive
```

---

## 7. Troubleshooting & Frequently Asked Questions

### Q: Why does GNOME Disks display `Operation not supported`?
**A**: UDisks/libblockdev relies on `cryptsetup` for BitLocker support. If the BitLocker drive was created with Windows 10/11 "Encrypt-on-Write" conversion, contains metadata extensions, or only had a TPM protector, `cryptsetup` returns `ENOTSUP` (Operation not supported). **Always use Method 2 (`dislocker`) with your 48-digit recovery key in this case.**

### Q: Mount fails with "The disk contains an unclean file system (fast startup or hibernation)"
**A**: Windows was shut down with "Fast Startup" enabled or was in hibernation. To mount it safely without risking filesystem corruption:
```bash
sudo mount -o loop,ro /media/bitlocker/dislocker-file /media/windows
```
Or to clear the hibernation flag (use with caution):
```bash
sudo ntfsfix /dev/mapper/bitlk_drive
```

### Q: Where can I find my BitLocker recovery key?
**A**:
1. Sign in to your Microsoft Account at [https://account.microsoft.com/devices/recoverykey](https://account.microsoft.com/devices/recoverykey).
2. For Work or School accounts, check Azure Active Directory / Intune portal.
3. Check printed documents or USB flash drives saved during initial BitLocker setup.
