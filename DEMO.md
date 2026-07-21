# DEMO

This document demonstrates the main features of **rebase-backup.sh**.

---

# 1. Successful Backup

### Command

```bash
./rebase-backup.sh \
    -s ~/data \
    -d ~/backups
```

### Expected Output

```text
[INFO] Backup process started!!
[INFO] Backup has been created: /home/user/backups/backup-2026-06-22_20-30-15.tar.gz
[INFO] Backup Completed Successfully!!
[INFO] Keeping only the newest 7 backups.
[INFO] Cleaning up all temporary files!!
```

### Result

A compressed archive is created inside the backup directory.

Example:

```text
backup-2026-06-22_20-30-15.tar.gz
```

---

# 2. Retention Cleanup

Run the script several times using a retention count of 2:

```bash
./rebase-backup.sh \
    -s ~/data \
    -d ~/backups \
    -r 2
```

### Before Cleanup

```text
backup-2026-06-22_20-20-00.tar.gz
backup-2026-06-22_20-21-00.tar.gz
backup-2026-06-22_20-22-00.tar.gz
backup-2026-06-22_20-23-00.tar.gz
backup-2026-06-22_20-24-00.tar.gz
```

### After Cleanup

```text
backup-2026-06-22_20-23-00.tar.gz
backup-2026-06-22_20-24-00.tar.gz
```

The older backups are automatically removed, leaving only the newest two archives.

---

# 3. Failure Notification

Run the script with an invalid source directory:

```bash
./rebase-backup.sh \
    -s /path/does/not/exist \
    -d ~/backups \
    -w "YOUR_DISCORD_WEBHOOK"
```

### Expected Log Output

```text
[ERROR] Your backup failed on line 152
[ERROR] The command that failed is: tar
[INFO] Sending Discord notification...
[INFO] Discord notification sent
```

### Discord Notification

A message similar to the following is sent to the configured Discord channel:

```text
🚨 Backup failed on hostname | line: 152 | Command: tar
```

---

# 4. Cron Scheduling

Example crontab entry:

```cron
*/10 * * * * /absolute/path/to/rebase-backup.sh \
-s /absolute/path/to/source \
-d /absolute/path/to/backups \
-r 7 \
>> /home/username/backup.log 2>&1
```

This runs the backup every 10 minutes.

---

# 5. ShellCheck

Run:

```bash
shellcheck rebase-backup.sh
```

Expected result:

```text
No issues detected.
```

---

# Summary

The backup utility successfully demonstrates:

* Command-line argument parsing with `getopts`
* Input validation
* Timestamped compressed backups
* Automatic retention cleanup
* Timestamped logging
* Temporary file cleanup using `trap`
* Discord webhook failure notifications
* Safe execution with `flock`
* Cron compatibility
* ShellCheck compliance
