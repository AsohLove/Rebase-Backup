#!/usr/bin/env bash
set -euo pipefail


usage(){
    cat <<EOF 
Usage: 
    rebase-backup.sh -s SOURCE_DIR -d BACKUP_DIR [-r RETENTION] [-w WEBHOOK_URL] [-v] [-h]

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
            RETENTION="$OPTARG"
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

