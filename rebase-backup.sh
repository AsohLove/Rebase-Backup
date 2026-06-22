#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR=""
BACKUP_DIR=""
WEBHOOK_URL=""
VERBOSE=false
RETENTION_COUNT=7

LOG_FILE="$HOME/backup.log"
TEMP_DIR=$(mktemp -d)


log() {
    local level="$1"
    echo "[$(date '+%F %T')] [$level] ${*:2}" \
    | tee -a "$LOG_FILE" >&2
}

log "Backup process started!!"

usage(){
    cat <<EOF 
Usage: 
    rebase-backup.sh -s SOURCE_DIR -d BACKUP_DIR [-r RETENTION_COUNT] [-w WEBHOOK_URL] [-v] [-h]

Options: 
    -s  Source directory
    -d  Backup directory
    -r  Number of backups to keep with a default of 7
    -w  webhook URL(this is optional)
    -v  Verbose mode
    -h  Show help
EOF
}

cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        log INFO "Cleaning up all temporary files!!"
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT 

while getopts ":s:d:r:w:vh" opt 
do 
    case "$opt" in 
        s)
            SOURCE_DIR="$OPTARG"
            ;;
        d)
            BACKUP_DIR="$OPTARG"
            ;;
        r)
            RETENTION_COUNT="$OPTARG"
            ;;
        w) 
            WEBHOOK_URL="$OPTARG"
            ;;
        v) 
            VERBOSE=true
            ;;
        h)
            usage
            exit 0
            ;;
        :)
            echo "The option -$OPTARG requires a value" >&2
            usage
            exit 1
            ;;

        \?) 
            echo "You have entered an unknown option: -$OPTARG" >&2
            usage
            exit 1
            ;;

    esac
done
 
  [ -z "$SOURCE_DIR" ] && { log ERROR "You are missing the source directory(-s)"; exit 1; }
  [ -z "$BACKUP_DIR" ] && { log ERROR "You are missing the backup directory(-d)"; exit 1; }



if [ ! -d "$SOURCE_DIR" ]; then
    log ERROR "The source directory you entered does not exist: $SOURCE_DIR"
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    log ERROR "The backup directory you entered does not exist: $BACKUP_DIR"
    exit 1
fi

if ! [[ "$RETENTION_COUNT" =~ ^[0-9]+$ ]]; then
    log ERROR "Retention count must be an positive integer(default is 7)"
    exit 1
fi

if [ "$RETENTION_COUNT" -le 0 ]; then
    log ERROR "The retention count must be greater than 0"
    exit 1
fi

if [[ -n "$WEBHOOK_URL" && ! "$WEBHOOK_URL" =~ ^https:// ]]; then
    log ERROR "The Webhook URL must start with https://"
    exit 1
fi


timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
backup_name="backup-${timestamp}.tar.gz"

backup_path="${BACKUP_DIR}/${backup_name}"

temp_backup="${TEMP_DIR}/${backup_name}"

tar -czf "$temp_backup" -C "$SOURCE_DIR" .

[ -f "$temp_backup" ] || {
    log ERROR "The backup creation process failed"
    exit 1
}
mv "$temp_backup" "$backup_path"

log INFO "Backup has been created: $backup_path "

mapfile -t backupFiles < <(
    ls -1t "$BACKUP_DIR"/backup-*.tar.gz 2>/dev/null
) 

for ((i=RETENTION_COUNT; i<${#backupFiles[@]}; i++ )); do
    if rm -f "${backupFiles[$i]}"; then
        log INFO "Old backups have been deleted: ${backupFiles[$i]}"
    fi
    
done


log INFO "Keeping only the newest $RETENTION_COUNT backups."

log INFO "Backup Completed Successfully!!"



