# SeibuRescue - 暗号化ディスク解除マニュアル（BitLocker & LUKS 対応）

本マニュアルでは、**SeibuRescue** 環境において、**Windows BitLocker** および **Linux LUKS** で暗号化されたディスク／パーティションのロックを解除し、データをマウントしてアクセスするための手順を解説します。

---

## 目次
1. [概要と事前準備](#1-概要と事前準備)
2. [手順 1: 暗号化パーティションの確認（デバイス名特定）](#2-手順-1-暗号化パーティションの確認デバイス名特定)
3. [方法 1: GUIツール（Disks / ディスク）による解除](#3-方法-1-guiツールdisks--ディスクによる解除)
4. [方法 2: `dislocker` による BitLocker 解除（Windows 10/11 推奨）](#4-方法-2-dislocker-による-bitlocker-解除windows-1011-推奨)
5. [方法 3: `cryptsetup` コマンドによる解除](#5-方法-3-cryptsetup-コマンドによる解除)
6. [方法 4: Linux LUKS 暗号化パーティションの解除](#6-方法-4-linux-luks-暗号化パーティションの解除)
7. [トラブルシューティングとよくある質問（FAQ）](#7-トラブルシューティングとよくある質問faq)

---

## 1. 概要と事前準備

### SeibuRescue に収録されているツール
SeibuRescue には、以下のディスク復号・管理ツールが標準搭載されています：
- **GNOME Disks（ディスク / `gnome-disks`）**: デスクトップ上にショートカットがあるGUIディスク管理ツール。
- **`dislocker`**: Windows BitLocker 専用の復号ユーティリティ（FUSEベース）。回復キー、パスワード、`.bek` キーファイルによる確実な復号に対応。
- **`cryptsetup`**: Linux カーネル（dm-crypt）ネイティブの暗号化管理ツール（BitLocker `--type bitlk` および LUKS に対応）。
- **`libblockdev-plugins-all`**: 暗号化プラグインライブラリ群。

### 事前に用意するもの（BitLocker の場合）
Windows の BitLocker ドライブを解除するには、以下のいずれかの情報が必要です：
- **BitLocker 回復キー（48桁の数値）**: 6桁×8グループの数字（例: `123456-789012-345678-901234-567890-123456-789012-345678`）。
  - ※ Microsoft アカウントに紐付いている場合、[https://account.microsoft.com/devices/recoverykey](https://account.microsoft.com/devices/recoverykey) から確認可能です。
- **ユーザーパスワード**: パスワード保護が設定されている場合。
- **回復キーファイル（`.bek`）**: 初期設定時にUSBメモリ等へ保存されたファイル。

---

## 2. 手順 1: 暗号化パーティションの確認（デバイス名特定）

ターミナルを開き（デスクトップ右クリック → 「Open Terminal」またはアプリケーションメニューから起動）、以下のコマンドを実行します：

```bash
lsblk -f
```

出力結果の `FSTYPE` 列を確認し、`BitLocker` または `crypto_LUKS` と表示されているパーティションを探します：

```text
NAME        FSTYPE      LABEL       UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
nvme0n1                                                                                 
├─nvme0n1p1 vfat        SYSTEM      A1B2-C3D4                                           
├─nvme0n1p2                                                                             
├─nvme0n1p3 BitLocker   Windows     01234567-89AB-CDEF...                               
└─nvme0n1p4 ntfs        Recovery    FEDCBA98-7654-3210...                               
```

上記の例では、対象パーティションは `/dev/nvme0n1p3` です。お使いの環境のデバイス名（例: `/dev/nvme0n1p3` や `/dev/sda3`）を控えておきます。

メタデータの詳細を確認したい場合は、以下を実行します：
```bash
sudo cryptsetup bitlkDump /dev/nvme0n1p3
```

---

## 3. 方法 1: GUIツール（Disks / ディスク）による解除

1. デスクトップ上の **Disks（ディスク）** アイコンをダブルクリックして開きます。
2. 左側のリストから該当するドライブを選択します。
3. ボリューム構成図から、鍵アイコン（🔒）が付いている暗号化パーティションをクリックします。
4. ボリューム下部にある **アンロック（鍵/再生アイコン）** ボタンをクリックします。
5. パスフレーズまたは 48桁の回復キーを入力して解除を実行します。

> **⚠️ 「Operation not supported（操作はサポートされていません）」と表示される場合:**
> 最新の Windows 10/11 の BitLocker（書き込み時暗号化「Encrypt-on-Write」やメタデータ拡張、TPM保護など）では、GUI のバックエンド（udisks2）が対応できず、このエラーが発生することがあります。
> **このエラーが出た場合は、以下の「方法 2（`dislocker`）」を使用してください。**

---

## 4. 方法 2: `dislocker` による BitLocker 解除（Windows 10/11 推奨）

`dislocker` は Linux 上で BitLocker パーティションを解除する最も堅牢かつ互換性の高いツールです。

### ステップ 2.1: マウント用ディレクトリの作成
ターミナルで仮想ディスク用とファイルシステム用のフォルダを作成します：
```bash
sudo mkdir -p /media/bitlocker /media/windows
```

### ステップ 2.2: `dislocker` で暗号化を解除

**パターン A: 48桁の回復キーを使用する場合（最も確実）**
パーティション名（`/dev/nvme0n1p3`）と48桁の回復キーを指定します：
```bash
sudo dislocker -v -V /dev/nvme0n1p3 -p123456-789012-345678-901234-567890-123456-789012-345678 -- /media/bitlocker
```

**パターン B: パスワードを使用する場合**
```bash
sudo dislocker -v -V /dev/nvme0n1p3 -u"設定したパスワード" -- /media/bitlocker
```

**パターン C: `.bek` キーファイルを使用する場合**
```bash
sudo dislocker -v -V /dev/nvme0n1p3 -f /path/to/keyfile.bek -- /media/bitlocker
```

コマンドが正常に完了すると、`/media/bitlocker/` ディレクトリ内に復号された仮想イメージファイル `dislocker-file` が生成されます。

### ステップ 2.3: 復号されたドライブをマウント
生成された仮想ファイルをマウントして、通常のフォルダとして中身にアクセスします：

**読み書き可能（Read-Write）でマウントする場合:**
```bash
sudo mount -o loop,rw /media/bitlocker/dislocker-file /media/windows
```

**読み取り専用（Read-Only）でマウントする場合（データ保護・高速スタートアップ時推奨）:**
```bash
sudo mount -o loop,ro /media/bitlocker/dislocker-file /media/windows
```

これで、`/media/windows` フォルダから復号されたすべてのファイル・ディレクトリにアクセスできるようになります。

### ステップ 2.4: 作業終了時のアンマウント（安全な切断）
作業が完了したら、以下の順序でアンマウントします：
```bash
sudo umount /media/windows
sudo umount /media/bitlocker
```

---

## 5. 方法 3: `cryptsetup` コマンドによる解除

Linux カーネルの標準機構（dm-crypt）を利用してダイレクトにマッピングする方法です。

### ステップ 3.1: ボリュームのオープン
以下のコマンドを実行し、仮想デバイス名（例: `bitlk_drive`）を指定して開きます：
```bash
sudo cryptsetup open --type bitlk /dev/nvme0n1p3 bitlk_drive
```

プロンプトが表示されたら、BitLocker パスワード、または 48桁の回復キーを入力（ペースト）します。

### ステップ 3.2: 解除されたボリュームのマウント
解除が成功すると、`/dev/mapper/bitlk_drive` としてアクセス可能になります：
```bash
sudo mkdir -p /media/windows
sudo mount /dev/mapper/bitlk_drive /media/windows
```

### ステップ 3.3: 作業終了時の切断
```bash
sudo umount /media/windows
sudo cryptsetup close bitlk_drive
```

---

## 6. 方法 4: Linux LUKS 暗号化パーティションの解除

Linux システムの LUKS 暗号化パーティションを解除する手順です。

### GUI（Disks）で解除する場合:
**Disks** アプリで該当パーティションを選択し、アンロックアイコンをクリックしてパスフレーズを入力します。

### コマンドラインで解除する場合:
```bash
# 1. LUKS デバイスを開く
sudo cryptsetup luksOpen /dev/sda2 luks_drive

# 2. マウントする
sudo mkdir -p /media/linux_drive
sudo mount /dev/mapper/luks_drive /media/linux_drive

# 3. 作業終了時の切断
sudo umount /media/linux_drive
sudo cryptsetup luksClose luks_drive
```

---

## 7. トラブルシューティングとよくある質問（FAQ）

### Q1: GNOME Disks で「Operation not supported（操作はサポートされていません）」と出る理由は？
**回答**: 
Windows 10/11 の一部の BitLocker 構成（暗号化変換処理の途中、Encrypt-on-Write、TPM のみの構成など）は、カーネルの `cryptsetup bitlk` では直接開けず `ENOTSUP` エラーとなります。Disks アプリは内部でこの機能を利用しているため同様のエラーになります。  
**この場合は、必ず「方法 2（`dislocker`）」と 48桁の回復キーをご利用ください。**

### Q2: マウント時に「The disk contains an unclean file system（高速スタートアップまたは休止状態）」とエラーが出る
**回答**: 
Windows が「高速スタートアップ」有効のままシャットダウンされたか、休止状態で電源が切られた状態です。  
ファイル破損を防ぐため、以下のように読み取り専用（`ro`）でマウントしてください：
```bash
sudo mount -o loop,ro /media/bitlocker/dislocker-file /media/windows
```

### Q3: 48桁の BitLocker 回復キーはどこで確認できますか？
**回答**:
1. 個人用 Microsoft アカウントの場合：[https://account.microsoft.com/devices/recoverykey](https://account.microsoft.com/devices/recoverykey) にサインインして確認。
2. 職場または学校のアカウントの場合：Azure Active Directory / Microsoft Intune の管理ポータルから確認。
3. 初期セットアップ時に印刷した用紙、または USB メモリ内に保存されたテキストファイル。
