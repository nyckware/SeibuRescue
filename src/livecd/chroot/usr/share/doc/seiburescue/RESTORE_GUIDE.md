# SeibuRescue - Complete System & Disk Restore Guide (Restore-Only Edition)

This guide provides a comprehensive, step-by-step tutorial on how to restore a system or disk backup image using the **SeibuRescue (Restore-Only)** variant.

---

## Table of Contents
1. [Important Warnings & Overview](#1-important-warnings--overview)
2. [Step 1: Booting the PC from the SeibuRescue USB Drive](#2-step-1-booting-the-pc-from-the-seiburescue-usb-drive)
3. [Step 2: Launching SeibuRescue (Restore-Only)](#3-step-2-launching-seiburescue-restore-only)
4. [Step 3: Selecting Image Location (Local Drive or Network Share)](#4-step-3-selecting-image-location-local-drive-or-network-share)
5. [Step 4: Selecting the Backup Image to Restore](#5-step-4-selecting-the-backup-image-to-restore)
6. [Step 5: Selecting the Target Destination Drive](#6-step-5-selecting-the-target-destination-drive)
7. [Step 6: Selecting Partitions to Restore & Partition Table Mapping](#7-step-6-selecting-partitions-to-restore--partition-table-mapping)
8. [Step 7: Confirming Overwrite & Starting the Restore](#8-step-7-confirming-overwrite--starting-the-restore)
9. [Step 8: Restoration Process & Progress Monitoring](#9-step-8-restoration-process--progress-monitoring)
10. [Step 9: Completion & First System Boot](#10-step-9-completion--first-system-boot)
11. [Troubleshooting & Frequently Asked Questions](#11-troubleshooting--frequently-asked-questions)

---

## 1. Important Warnings & Overview

> [!CAUTION]
> **DATA OVERWRITE WARNING**: Restoring a disk backup image will **completely overwrite and replace all existing data** on the destination drive or partition. Ensure you select the correct destination drive before confirming the restore operation!

### About the Restore-Only Variant
The **Restore-Only** version of SeibuRescue is specifically streamlined for fast disaster recovery, factory technician deployments, and field operations. Non-essential backup and cloning options are removed from the interface, and the desktop presents only the essential maintenance utilities (**SeibuRescue**, **GNOME Disks**, and **ARandR Display Manager**).

---

## 2. Step 1: Booting the PC from the SeibuRescue USB Drive

To use SeibuRescue, the target computer must be booted directly from the SeibuRescue USB flash drive rather than its internal operating system.

### Method A: Using the One-Time Boot Menu (Recommended)
1. Completely power off the target computer.
2. Insert your **SeibuRescue USB flash drive** into an available USB port.
3. Power on the computer and **immediately press the Boot Menu key repeatedly** (approx. once per second) until the Boot Device Selection Menu appears:

| Manufacturer | Typical Boot Menu Key |
| :--- | :--- |
| **Dell** | `F12` |
| **HP / Compaq** | `F9` or `Esc` then `F9` |
| **Lenovo / ThinkPad** | `F12` (or `Enter` then `F12`) |
| **ASUS** | `F8` or `Esc` |
| **Acer** | `F12` (if enabled) or `Esc` |
| **Toshiba / Dynabook** | `F12` |
| **Fujitsu** | `F12` |
| **Generic / Industrial / Others** | `F11`, `F12`, `F8`, or `Esc` |

4. In the Boot Menu list, select your **USB drive** (often listed as `UEFI: USB Flash Drive`, `USB: Generic Flash Disk`, or by brand name like `SanDisk` / `Kingston`).
5. Press **Enter** to boot.

### Method B: Changing Boot Priority in BIOS / UEFI Setup
If your computer does not display a temporary boot menu:
1. Power on the PC and press the **BIOS Setup key** repeatedly:
   - Common keys: **`Del`** (Delete), **`F2`**, or **`F10`**.
2. Navigate to the **Boot** or **Startup** tab using the keyboard arrow keys.
3. Under **Boot Option Priorities** (or *Boot Device Priority*), move the **USB Flash Drive** to the top of the list (`1st Boot Device`).
4. On older industrial computers (e.g., machines with Pentium 4 / Atom or Windows XP/2000), ensure **Legacy Boot / CSM** is enabled.
5. Save changes and exit (usually by pressing **`F10`** -> *Save & Exit*).
6. The PC will restart and load the SeibuRescue bootloader automatically.

---

## 3. Step 2: Launching SeibuRescue (Restore-Only)

1. The desktop environment loads automatically into a clean workspace.
2. In the **Restore-Only** edition, the **SeibuRescue** restore wizard opens directly. (If closed, double-click the **SeibuRescue** icon on the desktop).
3. The restore wizard guides you through the process step-by-step.

---

## 4. Step 3: Selecting Image Location (Local Drive or Network Share)

Select where your previously created backup image files are currently located.

![Step 1: Select Image Location](images/restore/restore_step1.png)
*(Image reference: `docs/images/restore/restore_step1.png` - Image location selection)*

- **Connected directly to my computer**:
  - Select this if the backup image is on an external USB hard disk, a secondary drive, or on the same USB drive's data partition (e.g., `BACKUPS`).
  - From the partition table, highlight the drive partition containing the backup folder.
- **Shared over a network**:
  - Select this if the image is stored on a local network server, NAS, or Windows Shared Folder via **SMB/CIFS**, **NFS**, or **SSH/SFTP**.
- Click **Next >** to continue.

---

## 5. Step 4: Selecting the Backup Image to Restore

Browse the directory list and choose the specific backup image archive to restore.

![Step 2: Select Backup Image Folder](images/restore/restore_step2.png)
*(Image reference: `docs/images/restore/restore_step2.png` - Backup folder browser)*

- Navigate through your folders to find the image folder.
- Standard SeibuRescue backup folders are named:
  ```text
  YYYY-MM-DD-HHMM-img-seiburescue
  ```
- Click on the backup folder to select it. SeibuRescue will verify the integrity of the image metadata.
- Click **Next >** to proceed.

---

## 6. Step 5: Selecting the Target Destination Drive

Choose the physical storage drive in the computer that will be overwritten with the restored backup.

![Step 3: Select Destination Drive](images/restore/restore_step3.png)
*(Image reference: `docs/images/restore/restore_step3.png` - Target drive selection)*

> [!WARNING]
> Carefully check the drive number, model name (e.g., `Internal SSD`, `SATA HDD`), and capacity! All existing data on the drive selected here will be overwritten.

- Click on the destination drive in the table.
- Click **Next >** to continue.

---

## 7. Step 6: Selecting Partitions to Restore & Partition Table Mapping

Configure which partitions from the backup image should be written to the target disk.

![Step 4: Select Partitions to Restore](images/restore/restore_step4.png)
*(Image reference: `docs/images/restore/restore_step4.png` - Partition table mapping)*

- **Restore Partition Table**:
  - Ensure the partition table checkbox (e.g., `Restore partition table (MBR/GPT)`) is checked if performing a full system restoration. This reconstructs the original partition layout and boot records.
- **Partition Selection**:
  - Leave all partitions checked to restore the entire operating system, recovery partitions, and data volumes.
- **Restoring to a Smaller Drive**:
  - If restoring to a smaller disk, SeibuRescue automatically adjusts partition boundaries as long as the used filesystem data fits within the smaller target drive.
- Click **Next >** to proceed to the confirmation screen.

---

## 8. Step 7: Confirming Overwrite & Starting the Restore

A final review screen is shown before any disk write operations occur.

![Step 5: Confirm Restore Configuration](images/restore/restore_step5.png)
*(Image reference: `docs/images/restore/restore_step5.png` - Final review screen)*

- Double-check:
  - **Source Backup Image Path**
  - **Target Destination Drive & Serial/Model**
- **Action on Completion**: Select *"Do nothing"*, *"Reboot computer"*, or *"Shut down computer"* when the restore finishes.
- Click **Next >**.

A safety confirmation popup dialog will appear:

![Overwrite Confirmation Dialog](images/restore/overwrite_are_you_sure.png)
*(Image reference: `docs/images/restore/overwrite_are_you_sure.png` - Are you sure dialog)*

- Click **Yes** to permanently commit changes and start writing data to the target disk.

---

## 9. Step 8: Restoration Process & Progress Monitoring

SeibuRescue begins uncompressing and writing the filesystem blocks to the target disk using **Partclone**.

![Step 8: Restoration in Progress](images/restore/restore_progress.png)
*(Image reference: `docs/images/restore/restore_progress.png` - Progress bar)*

- Displays real-time write speed (MB/s or GB/min), elapsed time, estimated time remaining, and partition percentage.
- *Do not power off the machine or remove any cables during this stage.*

---

## 10. Step 9: Completion & First System Boot

When all partitions and boot sectors are successfully restored, the completion dialog appears.

![Step 9: Restoration Summary](images/restore/restore_summary.png)
*(Image reference: `docs/images/restore/restore_summary.png` - Completion summary)*

1. The summary displays the total duration and transfer statistics.
2. Click **Exit** to close the wizard.
3. Click the power icon in the lower-right panel and select **Reboot** or **Shut Down**.
4. **Remove the SeibuRescue USB drive** during restart so the computer boots directly into the newly restored operating system!

---

## 11. Troubleshooting & Frequently Asked Questions

### Common Questions
- **Q: The target PC displays "No bootable device found" after restoring.**
  - **A**: Ensure the PC's BIOS/UEFI boot mode matches the original system. For older MBR backups, enable *Legacy Boot / CSM* in the BIOS. For modern GPT backups, ensure *UEFI Boot* is enabled.
- **Q: Can I restore an image created on an Intel PC onto an AMD machine?**
  - **A**: Yes, the disk image is block-level. Modern Windows (10/11) and Linux automatically reconfigure drivers on first boot.
- **Q: Does SeibuRescue support restoring BitLocker partitions?**
  - **A**: Yes. BitLocker partitions backed up in RAW mode are restored sector-for-sector with their original encryption and keys intact.
