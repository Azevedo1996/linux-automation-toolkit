#!/bin/bash

# Script para localizar e tratar processos zumbi

echo "========================================="
echo "      Linux Automation Toolkit"
echo "         Zombie Hunter"
echo "========================================="

echo

ZOMBIES=$(ps -eo pid,ppid,state,comm --no-headers | awk '$3 ~ /^Z/')

if [ -z "$ZOMBIES" ]; then
    echo "Nenhum processo zumbi encontrado no sistema."
    exit 0
fi

echo "Processos zumbi encontrados:"
echo

while read -r PID PPID STATE CMD; do
    [ -z "$PID" ] && continue

    echo "PID Zumbi : $PID"
    echo "PID Pai   : $PPID"
    echo "Comando   : $CMD"

    read -rp "Deseja enviar SIGKILL (kill -9) para o processo pai $PPID? [s/N]: " RESP

    case "$RESP" in
        s|S|sim|SIM)
            if kill -9 "$PPID" 2>/dev/null; then
                echo "SIGKILL enviado para o processo pai $PPID."
            else
                echo "Falha ao enviar SIGKILL para $PPID. Verifique permissões."
            fi
            ;;
        *)
            echo "Ação ignorada para o processo pai $PPID."
            ;;
    esac

    echo "-----------------------------------------"
done <<< "$ZOMBIES"
