#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR=""
BACKUP_DIR=""
WEBHOOK_URL=""
VERBOSE=false
RETENTION_DAYS="7"

LOG_FILE="$HOME/backup.log"


log() {
    local level="$1"
    echo "[$(date '+%F %T')] [$level] ${*:2}" \
    | tee -a "$LOG_FILE" >&2
}

usage(){
    cat <<EOF 
Usage: 
    rebase-backup.sh -s SOURCE_DIR -d BACKUP_DIR [-r RETENTION_DAYS] [-w WEBHOOK_URL] [-v] [-h]

Options: 
    -s  Source directory
    -d  Backup directory
    -r  Retention in days with a default of 7
    -w  webhook URL(this is optional)
    -v  Verbose mode
    -h  Show help
EOF
}

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
            RETENTION_DAYS="$OPTARG"
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

if ! [[ "$RETENTION_DAYS" =~ ^[0-9]+$ ]]; then
    log ERROR "Retention days must be an integer(default is 7)"
    exit 1
fi

if [ "$RETENTION_DAYS" -le 0 ]; then
    log ERROR "The retention days must be greater than 0"
    exit 1
fi

if [[ -n "$WEBHOOK_URL" && ! "$WEBHOOK_URL" =~ ^https:// ]]; then
    log ERROR "The Webhook URL must start with https://"
    exit 1
fi

timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
backup_name="backup-${timestamp}.tar.gz"

backup_path="${BACKUP_DIR}/${backup_name}"

tar -czf "$backup_path" -C "$SOURCE_DIR" .

log INFO "Backup has been created: $backup_path "

