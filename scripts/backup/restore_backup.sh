#!/bin/bash

BACKUP_DIR="${1:-./../../backups/daily}"

mapfile -t FILES < <(find "$BACKUP_DIR" -maxdepth 1 -name '*.tar.gz' | sort)

if [ ${#FILES[@]} -eq 0 ]; then
    echo "Nenhum backup encontrado."
    exit 1
fi

echo "Backups disponíveis:"
for i in "${!FILES[@]}"; do
    echo "$((i+1))) $(basename "${FILES[$i]}")"
done

read -rp "Selecione o backup: " CHOICE
FILE="${FILES[$((CHOICE-1))]}"

[ -z "$FILE" ] && exit 1

tar -xzf "$FILE" -C /
echo "Restauração concluída."
