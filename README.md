# Rebase Backup

## :beginner: Overview 

A production-style Bash backup utility that creates compressed backups of a directory, automatically manages backup retention, logs every operation, and optionally sends Discord webhook notifications when a backup fails.

This project was built to demonstrate practical Bash scripting techniques including command-line argument parsing, error handling, logging, traps, scheduling with cron, and safe automation practices.

---

## :sparkles: Features

* Create compressed (`.tar.gz`) backups of any directory
* Timestamped backup archives
* Configurable backup retention (keep only the newest **N** backups)
* Timestamped log file with `INFO`, `WARN`, and `ERROR` levels
* Automatic cleanup of temporary files using `trap`
* Discord webhook notifications on backup failures (optional)
* Safe to run repeatedly
* Prevents multiple backup processes from running simultaneously using `flock`
* Suitable for scheduled execution using `cron`
* Passes ShellCheck with zero warnings

---


## Installation

Clone the repository:

```bash
git clone https://github.com/AsohLove/Rebase-Backup.git
```

Move into the project directory:

```bash
cd rebase-backup
```

Make the script executable:

```bash
chmod +x rebase-backup.sh
```

---

## Usage

Run the following command on the terminal;

```bash
./rebase-backup.sh -s SOURCE_DIR -d BACKUP_DIR [OPTIONS]
```

---

## Command-Line OPTIONS

| Option | Description                              | Required |
| ------ | ---------------------------------------- | -------- |
| `-s`   | Source directory to back up              | ✅        |
| `-d`   | Destination directory for backups        | ✅        |
| `-r`   | Number of backups to retain (default: 7) | No       |
| `-w`   | Discord webhook URL for failure alerts   | No       |
| `-v`   | Verbose mode                             | No       |
| `-h`   | Show help message                        | No       |

---

## Examples

Create a backup using the default retention count:

```bash
./rebase-backup.sh \
    -s ~/Documents \
    -d ~/Backups
```

Keep only the newest five backups:

```bash
./rebase-backup.sh \
    -s ~/Documents \
    -d ~/Backups \
    -r 5
```

Create a backup with Discord failure notifications:

```bash
./rebase-backup.sh \
    -s ~/Documents \
    -d ~/Backups \
    -w https://discord.com/api/webhooks/your-webhook-url
```

---

## Backup Naming

Each backup is stored as:

```text
backup-YYYY-MM-DD_HH-MM-SS.tar.gz
```

Example:

```text
backup-2026-06-22_15-25-02.tar.gz
```

---

## Retention Policy

After every successful backup, the script automatically removes older backups, keeping only the newest **N** archives.

For example:

```
Retention Count = 3

Before:

backup-1.tar.gz
backup-2.tar.gz
backup-3.tar.gz
backup-4.tar.gz
backup-5.tar.gz

After:

backup-3.tar.gz
backup-4.tar.gz
backup-5.tar.gz
```

---

## Logging

The script writes timestamped logs to:

```text
~/backup.log
```

Example log output:

```text
[2026-06-22 20:46:23] [INFO] Backup process started!!
[2026-06-22 20:46:24] [INFO] Backup has been created.
[2026-06-22 20:46:24] [INFO] Old backup deleted.
[2026-06-22 20:46:24] [INFO] Backup Completed Successfully!!
```

---

## Discord Notifications

If a Discord webhook URL is supplied using `-w`, the script sends a notification whenever a backup fails.

Example notification:

```
🚨 Backup failed on my-server | line: 152 | Command: tar
```

If no webhook is provided, the script simply logs the error locally.

---

## Scheduling with Cron

Example cron job that runs every 10 minutes:

```cron
*/10 * * * * /absolute/path/to/rebase-backup.sh \
-s /absolute/path/to/source \
-d /absolute/path/to/backups \
-r 7 \
-w "https://discord.com/api/webhooks/your-webhook" 
```

**NB**: Ensure that all paths used in the cron job are absolute paths.

---

## Safety Features

This utility includes several safeguards:

* Uses `set -Eeuo pipefail`
* Cleans temporary files automatically using `trap`
* Uses `flock` to prevent concurrent executions
* Validates all user input before starting
* Creates backups in a temporary directory before moving them to the final destination
* Stops immediately if any command fails

---

## Running ShellCheck

Verify the script using:

```bash
shellcheck rebase-backup.sh
```
---

## Project Structure

```
rebase-backup/
├── rebase-backup.sh
├── README.md
├── DEMO.md
└── .gitignore
```

---


- GitHub: [@loveasoh](https://github.com/AsohLove)
- Twitter: [@loveasoh](https://x.com/LoveTheModifier)
- LinkedIn: [@love asoh](https://www.linkedin.com/in/asohlove/)

:earth_africa: Based in Cameroon | Open for hybrid opportunities


## :lock: License
This project is [MIT](./LICENSE) licensed.
