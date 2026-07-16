#!/bin/bash

# Script de diagnóstico geral de saúde do sistema

clear

echo "========================================="
echo "   Linux Automation Toolkit - Health Check"
echo "========================================="

# Coleta uso atual de CPU utilizando top
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')

# Informações de memória em formato legível
MEM_INFO=$(free -h)
MEM_USED=$(free -h | awk '/Mem:/ {print $3}')
MEM_FREE=$(free -h | awk '/Mem:/ {print $7}')

# Uptime do sistema
UPTIME=$(uptime -p)

echo
printf "Uso atual de CPU: %.2f%%
" "$CPU_USAGE"
echo "Memória usada : $MEM_USED"
echo "Memória livre : $MEM_FREE"
echo "Uptime        : $UPTIME"

echo
echo "Top 3 partições mais cheias:"
df -h --output=source,pcent,target | tail -n +2 | sort -rk2 | head -3
