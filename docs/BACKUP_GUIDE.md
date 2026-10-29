# SeibuRescue - Complete System & Disk Backup Guide

This guide provides a comprehensive, step-by-step tutorial on how to create full disk and partition backups using **SeibuRescue**.

---

## Table of Contents
1. [Overview & Preparation](#1-overview--preparation)
2. [Step 0: Starting SeibuRescue](#2-step-0-starting-seiburescue)
3. [Step 1: Selecting the Source Drive](#3-step-1-selecting-the-source-drive)
4. [Step 2: Selecting Partitions to Back Up](#4-step-2-selecting-partitions-to-back-up)
5. [Step 3: Choosing the Destination Drive (Local or Network)](#5-step-3-choosing-the-destination-drive-local-or-network)
6. [Step 4: Selecting the Target Folder](#6-step-4-selecting-the-target-folder)
7. [Step 5: Naming the Backup Image](#7-step-5-naming-the-backup-image)
8. [Step 6: Compression Settings (Zstandard, Gzip, or Uncompressed)](#8-step-6-compression-settings-zstandard-gzip-or-uncompressed)
9. [Step 7: Confirming Configuration & Rescue Mode](#9-step-7-confirming-configuration--rescue-mode)
10. [Step 8: Backup Execution & Monitoring](#10-step-8-backup-execution--monitoring)
11. [Step 9: Completion & Verification](#11-step-9-completion--verification)
12. [Best Practices & Troubleshooting](#12-best-practices--troubleshooting)

---

## 1. Overview & Preparation

### What is SeibuRescue Backup?
SeibuRescue creates block-level, sector-accurate images of your storage drives. It utilizes **Partclone** to save only the used blocks of supported filesystems (NTFS, FAT32, ext2/3/4, exFAT, XFS, Btrfs, etc.), resulting in compact backup files and fast copy speeds.

### Pre-Backup Checklist
- **Destination Storage**: Ensure your target USB drive, external hard drive, or network share has enough free space to hold the backup image (typically 30% to 70% of the used space on the source disk depending on file types and compression).
- **Drive Health**: If backing up failing drives with bad sectors, ensure you enable the "Rescue Mode" option in Step 7.
- **BitLocker Drives**: If backing up an encrypted Windows drive, either unlock it first using the [Encrypted Disk Unlocking Guide](DISK_UNLOCK_GUIDE.md) to save files, or perform a raw partition backup.

---

## 2. Step 0: Starting SeibuRescue

When you boot your computer with the SeibuRescue USB drive:
1. The desktop environment loads automatically.
2. The **SeibuRescue** application will launch on your screen. (If closed, double-click the **SeibuRescue** icon on the desktop).
3. From the main menu, click the **Backup** button to begin the wizard.

---

## 3. Step 1: Selecting the Source Drive

Select the physical storage drive that you want to back up.

![Step 1: Select Drive To Backup](images/backup/backup_step1.png)
*(Image reference: `docs/images/backup/backup_step1.png` - Source drive selection)*

- **Drive List**: Displays all detected internal and external drives, along with their capacity, model name, and existing partition scheme.
- **Tip**: Verify the drive capacity and model name carefully to ensure you are selecting the intended source disk (e.g., `Drive #1 - 50GB ATA VBOX HARDDISK` or `Drive #1 - 512GB NVMe SSD`).
- **Advanced option**: Check *"Show hidden devices"* only if your storage device is not listed by default.
- Click **Next >** to continue.

---

## 4. Step 2: Selecting Partitions to Back Up

Choose which partitions of the selected drive to include in the backup image.

![Step 2: Select Partitions to Save](images/backup/backup_step2.png)
*(Image reference: `docs/images/backup/backup_step2.png` - Partition selection list)*

- **Recommended**: Leave **all partitions checked** if you want a complete, bootable clone of your operating system (including EFI system partition, MBR/bootloader, and recovery partitions).
- **Selective Backup**: You may uncheck non-essential data partitions if you only wish to image specific system volumes.
- Click **Next >** to proceed.

---

## 5. Step 3: Choosing the Destination Drive (Local or Network)

Select where the backup image files will be stored.

![Step 3: Select Destination Drive](images/backup/backup_step3.png)
*(Image reference: `docs/images/backup/backup_step3.png` - Destination location selection)*

- **Connected directly to my computer (Local Drive)**:
  - Choose this option to save the backup to an external USB drive, a secondary hard drive, or a dedicated data partition on your USB stick.
  - Select the destination partition from the table (e.g., `Drive 2, Partition 1 [NTFS]`).
- **Shared over a network**:
  - SeibuRescue supports **SMB/CIFS (Windows Shared Folder / NAS)**, **NFS**, and **SSH/SFTP**.
  - Selecting network storage will prompt you for server IP, share name, username, and password.
- Click **Next >** to continue.

---

## 6. Step 4: Selecting the Target Folder

Browse and select the directory on the destination drive where the backup folder will be created.

![Step 4: Select Destination Folder](images/backup/backup_step4.png)
*(Image reference: `docs/images/backup/backup_step4.png` - Directory browser)*

- Use the file browser to navigate to your desired storage folder (e.g., `/mnt/backup/` or your `Backups/` directory).
- You can create a new folder directly from the interface if needed.
- Click **Next >** to confirm.

---

## 7. Step 5: Naming the Backup Image

Specify the folder name for your new backup image.

![Step 5: Name Your Backup](images/backup/backup_step5.png)
*(Image reference: `docs/images/backup/backup_step5.png` - Backup name input)*

- **Default Format**: SeibuRescue automatically suggests a timestamped name using the format:
  ```text
  YYYY-MM-DD-HHMM-img-seiburescue
  ```
  *(Example: `2026-10-29-0915-img-seiburescue`)*
- **Custom Name**: You can customize this name (e.g., `CNC-Lathe-Machine01-WinXP-FullBackup`).
- **Description Field**: You can add optional notes (such as software versions, machine ID, or reasons for backup) which will be stored inside the image metadata.
- Click **Next >** to proceed.

---

## 8. Step 6: Compression Settings

Choose the compression algorithm and level for your backup files.

![Step 6: Customize Compression](images/backup/backup_step6_zstandard.png)
*(Image reference: `docs/images/backup/backup_step6_zstandard.png` - Compression options)*

- **Zstandard (zstd) - Recommended**:
  - Provides the best balance of high-speed compression and small file size.
  - Compression level: **Level 6** to **16** is recommended for production.
- **Gzip (gzip)**:
  - Highly compatible legacy format with standard compression.
- **Uncompressed**:
  - Disables compression completely. Fastest write speed, but requires destination space equal to the uncompressed data.
- Click **Next >** to review the summary.

---

## 9. Step 7: Confirming Configuration & Rescue Mode

Review all settings before the backup begins.

![Step 7: Confirm Backup Configuration](images/backup/backup_step7.png)
*(Image reference: `docs/images/backup/backup_step7.png` - Summary confirmation screen)*

- Review:
  - **Source Drive & Partitions**
  - **Destination Location & Folder Path**
  - **Compression Format & Estimated Parameters**
- **Rescue Option (Ignore Filesystem Inconsistencies & Bad Sectors)**:
  - Check this box **only** if the source drive has damaged sectors or filesystem errors that cause Partclone to abort.
- **Action on completion**: Choose *"Do nothing"*, *"Reboot computer"*, or *"Shut down computer"* when the backup finishes.
- Click **Next >** to start the backup.

---

## 10. Step 8: Backup Execution & Monitoring

SeibuRescue begins copying partition data.

![Step 8: Backup in Progress](images/backup/backup_progress.png)
*(Image reference: `docs/images/backup/backup_progress.png` - Real-time progress bar)*

- **Real-Time Statistics**:
  - Current transfer rate (MB/s or GB/min).
  - Elapsed time and estimated remaining time.
  - Percentage completed per partition and overall drive.
- *Do not disconnect the source or destination drives while the progress bar is active.*

---

## 11. Step 9: Completion & Verification

Once all partitions are processed, the success confirmation screen is displayed.

![Step 9: Backup Summary](images/backup/backup_summary.png)
*(Image reference: `docs/images/backup/backup_summary.png` - Successful completion dialog)*

- The summary screen displays total time elapsed, total bytes transferred, and compression ratio achieved.
- Click **Exit** to return to the main menu.
- Your backup image is now safely saved and ready to be restored at any time!

---

## 12. Best Practices & Troubleshooting

### Best Practices
1. **Verify Your Backup**: Use the **Verify Image** feature on the SeibuRescue main menu to ensure the backup files are not corrupt and can be read completely.
2. **Keep Multiple Generations**: Do not overwrite previous backups immediately; keep at least two historical snapshots of mission-critical systems.
3. **Explore Image Files**: If you only need to extract individual files from a backup image later, use the **Image Explorer** tool on the main menu to mount the backup without restoring the whole drive.

### Common Questions
- **Q: Can I restore a SeibuRescue backup to a smaller drive?**
  - Yes! SeibuRescue supports restoring to smaller drives as long as the actual data fits on the target drive.
- **Q: Are SeibuRescue images compatible with Clonezilla?**
  - Yes, SeibuRescue backup images are fully compatible with Clonezilla and vice versa.
