# SeibuRescue - USB Bootable Drive Creation Guide

This guide explains how to write (**burn**) the **SeibuRescue** ISO image to a USB flash drive across Windows, Linux, and macOS platforms.

---

## Table of Contents
1. [Overview & ISO Variant Selection](#1-overview--iso-variant-selection)
2. [Hardware & Software Prerequisites](#2-hardware--software-prerequisites)
3. [Method 1: Rufus (Windows - Recommended for Factory & Legacy PCs)](#3-method-1-rufus-windows---recommended-for-factory--legacy-pcs)
4. [Method 2: BalenaEtcher (Windows, macOS, Linux)](#4-method-2-balenaetcher-windows-macos-linux)
5. [Method 3: Linux Terminal (`dd` command)](#5-method-3-linux-terminal-dd-command)
6. [Method 4: Ventoy (Multi-Boot USB)](#6-method-4-ventoy-multi-boot-usb)
7. [Pro Tip: Creating a Dedicated Backup Partition on the Same USB](#7-pro-tip-creating-a-dedicated-backup-partition-on-the-same-usb)
8. [Verifying & Booting from the USB Drive](#8-verifying--booting-from-the-usb-drive)
9. [Frequently Asked Questions & Troubleshooting](#9-frequently-asked-questions--troubleshooting)

---

## 1. Overview & ISO Variant Selection

Before creating the bootable USB, choose the correct ISO image variant according to your machine's architecture and operational role:

| ISO Variant | Target Architecture | RAM Requirement | Intended Usage |
| :--- | :--- | :--- | :--- |
| **`SeibuRescue-24.04-amd64.iso`** | 64-bit (x86_64 / UEFI & BIOS) | 2GB+ RAM | Full edition: Backup, Restore, Clone, and Image Explorer. |
| **`SeibuRescue-18.04-i386.iso`** | 32-bit (i386 / Legacy BIOS) | 256MB – 512MB RAM | Full edition optimized for older factory PCs, Pentium 4, and Atom processors. |
| **`SeibuRescue-RestoreOnly-24.04-amd64.iso`** | 64-bit (x86_64 / UEFI & BIOS) | 2GB+ RAM | Streamlined recovery-only image for deployment technicians. |
| **`SeibuRescue-RestoreOnly-18.04-i386.iso`** | 32-bit (i386 / Legacy BIOS) | 256MB – 512MB RAM | Streamlined recovery-only image for factory machines. |

---

## 2. Hardware & Software Prerequisites

1. **USB Flash Drive**:
   - Minimum capacity: **4 GB** (2 GB is sufficient for the OS alone).
   - Recommended: **16 GB to 64 GB** if you wish to partition the remaining space to hold system backup images directly on the same drive.
2. **Downloaded ISO Image**:
   - Verify the checksum using `sha256sum SeibuRescue-*.iso` before writing.
3. **Backup existing USB data**:
   - Writing an ISO will overwrite all existing data on the USB stick. Ensure all important files on the flash drive are backed up beforehand.

---

## 3. Method 1: Rufus (Windows - Recommended for Factory & Legacy PCs)

**Rufus** is the recommended tool on Windows because it provides full control over partition schemes (MBR vs GPT) and boot modes (Legacy BIOS vs UEFI), which is critical for industrial computers.

### Step-by-Step Instructions:
1. Download **Rufus** (portable version recommended) from [https://rufus.ie](https://rufus.ie).
2. Insert your USB flash drive into the Windows PC.
3. Open Rufus and configure the following parameters:
   - **Device**: Select your USB flash drive from the dropdown list.
   - **Boot selection**: Click **SELECT** and browse to your `SeibuRescue-*.iso` file.
   - **Partition scheme**:
     - Select **MBR** *(Highly Recommended: boots on both Legacy BIOS industrial machines and modern UEFI motherboards)*.
   - **Target system**: **BIOS (or UEFI-CSM)**.
   - **Volume label**: You can enter `SEIBURESCUE`.
   - **File system**: `FAT32 (Default)`.
4. Click **START**.
5. When prompted with *"ISOHybrid image detected"*:
   - Select **Write in ISO Image mode (Recommended)** and click **OK**.
   - *(Note: If an older motherboard fails to boot, re-flash using "Write in DD Image mode")*.
6. Click **OK** on the warning stating all data will be destroyed.
7. Wait until the status bar shows **READY**. Click **CLOSE**.

---

## 4. Method 2: BalenaEtcher (Windows, macOS, Linux)

**BalenaEtcher** is an intuitive, cross-platform graphical tool.

### Step-by-Step Instructions:
1. Download and install BalenaEtcher from [https://etcher.balena.io](https://etcher.balena.io).
2. Insert your USB flash drive.
3. Open BalenaEtcher:
   - Click **Flash from file** and select your `SeibuRescue-*.iso`.
   - Click **Select target** and check your USB drive. *(Carefully verify the drive letter/capacity to avoid selecting internal drives)*.
   - Click **Flash!**
4. Enter administrator / root credentials if prompted.
5. Once the verification phase reaches 100%, safely eject the USB drive.

---

## 5. Method 3: Linux Terminal (`dd` command)

For Linux administrators, the native `dd` command produces a bit-for-bit sector copy without needing third-party software.

### Step-by-Step Instructions:
1. Open the terminal and identify the target USB drive node:
   ```bash
   lsblk -d -o NAME,SIZE,MODEL,TRAN
   ```
   *(Identify your USB device, e.g., `/dev/sdb` or `/dev/sdc`. Do NOT specify a partition number like `/dev/sdb1`)*.

2. Unmount any automatically mounted partitions:
   ```bash
   sudo umount /dev/sdX* 2>/dev/null || true
   ```

3. Write the ISO to the USB device:
   ```bash
   sudo dd if=SeibuRescue-24.04-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync
   ```
   *(Replace `SeibuRescue-24.04-amd64.iso` with your ISO filename and `/dev/sdX` with your USB block device)*.

4. Once the terminal prompt returns, flush remaining write buffers:
   ```bash
   sync
   ```
5. You can now safely remove the USB stick.

---

## 6. Method 4: Ventoy (Multi-Boot USB)

**Ventoy** allows you to put multiple ISOs (e.g., both 64-bit and 32-bit versions) on a single USB stick by copying the `.iso` files directly into a storage folder.

### Step-by-Step Instructions:
1. Download and run Ventoy from [https://www.ventoy.net](https://www.ventoy.net).
2. Install Ventoy onto your USB flash drive.
3. Once formatted, a drive partition labeled `Ventoy` appears in your file manager.
4. Simply copy `SeibuRescue-24.04-amd64.iso` and/or `SeibuRescue-18.04-i386.iso` into the drive.
5. When booting the computer from the USB, Ventoy's graphical menu will let you select which SeibuRescue ISO to load.

> [!NOTE]
> **Industrial PC Compatibility Note**: While Ventoy is very convenient, certain older factory motherboards (especially Pentium 4 / early Atom systems from 2000–2010) may fail to initialize Ventoy's GRUB payload. For maximum compatibility with legacy factory PCs, flash the USB directly using **Rufus (MBR mode)** or **`dd`**.

---

## 7. Pro Tip: Creating a Dedicated Backup Partition on the Same USB

Since the SeibuRescue system requires less than 2 GB, a 32 GB or 64 GB flash drive leaves ample free space. You can partition the drive so it acts as both a **bootable rescue key** and a **backup storage repository**:

### Using KDE Partition Manager or GParted:
1. Boot into SeibuRescue or use a Linux workstation.
2. Open **Partition Editor** (GParted or KDE Partition Manager).
3. Select your USB drive from the top-right device list.
4. Resize or create a second partition in the unallocated space:
   - **File System**: **NTFS** (recommended for universal cross-platform compatibility with Windows, Linux, and large file support) or **exFAT**.
   - **Label**: `BACKUPS`.
5. Apply the changes.
6. When running SeibuRescue, this `BACKUPS` partition will immediately appear in **Step 3 (Destination Drive)** as local storage!

---

## 8. Verifying & Booting from the USB Drive

1. Completely shut down the target computer.
2. Connect your bootable USB drive to a direct USB 2.0 or 3.0 port (avoid unpowered USB hubs).
3. Power on the PC and immediately tap the **Boot Menu key** repeatedly (once per second):

| Manufacturer / Motherboard | Boot Menu Key |
| :--- | :--- |
| **Dell** | `F12` |
| **HP / Compaq** | `F9` or `Esc` then `F9` |
| **Lenovo / ThinkPad** | `F12` |
| **ASUS** | `F8` or `Esc` |
| **Acer / Toshiba / Fujitsu / NEC** | `F12` |
| **Industrial Motherboards (Advantech, Kontron, etc.)** | `F11`, `F12`, `F8`, or `Esc` |

4. Select the USB flash drive and press **Enter**.
5. The SeibuRescue boot menu will appear, followed by the desktop environment.

---

## 9. Frequently Asked Questions & Troubleshooting

- **Q: The computer ignores the USB and boots straight into Windows.**
  - **A**: Ensure Fast Startup is disabled in Windows Control Panel, or enter BIOS Setup (`Del` / `F2`) and set the USB Flash Drive as the first boot priority.
- **Q: An older machine gives a black screen with blinking cursor or says "Operating System not found".**
  - **A**: The machine requires Legacy BIOS mode. Re-flash the USB drive using **Rufus** with **Partition scheme: MBR** and **Target system: BIOS (or UEFI-CSM)**, and write using **DD mode**. Also ensure you are using the 32-bit ISO (`SeibuRescue-18.04-i386.iso`) if the processor is 32-bit.
- **Q: Secure Boot Violation error appears on modern UEFI machines.**
  - **A**: Enter UEFI Setup (`F2` or `Del`) and temporarily disable **Secure Boot**.
