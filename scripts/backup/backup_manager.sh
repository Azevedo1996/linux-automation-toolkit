#!/bin/bash

# Linux Automation Toolkit - Backup Manager

CONFIG_FILE="backup.conf"
LOG_FILE="backup.log"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Arquivo $CONFIG_FILE não encontrado."
    exit 1
fi

source "$CONFIG_FILE"

mkdir -p "$BACKUP_DIR"

echo "[$(date '+%F %T')] Iniciando backup" >> "$LOG_FILE"

for DIR in $SOURCE_DIRS; do
    if [ -d "$DIR" ]; then
        NAME=$(basename "$DIR")
        DATE=$(date +%Y%m%d_%H%M%S)
        FILE="$BACKUP_DIR/${NAME}_${DATE}.tar.gz"

        tar -czf "$FILE" "$DIR"

        if [ $? -eq 0 ]; then
            sha256sum "$FILE" > "$FILE.sha256"
            echo "[OK] Backup criado: $FILE"
            echo "[$(date '+%F %T')] Backup criado: $FILE" >> "$LOG_FILE"
        else
            echo "[ERRO] Falha ao criar backup de $DIR"
        fi
    fi
done

find "$BACKUP_DIR" -type f -name '*.tar.gz' -mtime +$RETENTION_DAYS -delete
