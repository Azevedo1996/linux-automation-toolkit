#!/bin/bash

# Testador de conectividade TCP utilizando nmap-ncat (nc)

TARGETS_FILE="targets.txt"
GREEN='[0;32m'
RED='[0;31m'
NC='[0m'

# Validação do arquivo de entrada
if [ ! -f "$TARGETS_FILE" ]; then
    echo "Erro: arquivo '$TARGETS_FILE' não encontrado no diretório atual."
    exit 1
fi

while IFS= read -r line || [ -n "$line" ]; do
    line=$(echo "$line" | xargs)

    [ -z "$line" ] && continue
    [[ "$line" =~ ^# ]] && continue

    IP="${line%%:*}"
    PORT="${line##*:}"

    if nc -z -w 2 "$IP" "$PORT" >/dev/null 2>&1; then
        echo -e "${GREEN}[SUCCESS]${NC} ${IP}:${PORT}"
    else
        echo -e "${RED}[FAILED]${NC} ${IP}:${PORT}"
    fi

done < "$TARGETS_FILE"
