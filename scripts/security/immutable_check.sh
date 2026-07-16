#!/bin/bash

# Linux Automation Toolkit - Security Module
# Auditoria de arquivos críticos protegidos por atributo de imutabilidade.

GREEN='[0;32m'
YELLOW='[1;33m'
RED='[0;31m'
NC='[0m'

FILES=(
    /etc/passwd
    /etc/shadow
    /etc/group
    /etc/gshadow
    /etc/sudoers
)

echo "==============================================="
echo " Linux Automation Toolkit - Immutable Check"
echo "==============================================="
echo

if ! command -v lsattr >/dev/null 2>&1; then
    echo -e "${RED}Erro: comando lsattr não encontrado.${NC}"
    echo "Instale o pacote e2fsprogs antes de executar este script."
    exit 1
fi

for FILE in "${FILES[@]}"; do

    if [ ! -e "$FILE" ]; then
        echo -e "${YELLOW}[WARNING] Arquivo não encontrado: $FILE${NC}"
        continue
    fi

    ATTR=$(lsattr "$FILE" 2>/dev/null | awk '{print $1}')

    if echo "$ATTR" | grep -q 'i'; then
        echo -e "${GREEN}[OK] O arquivo $FILE está protegido (imutável)${NC}"
    else
        echo -e "${RED}[WARNING] O arquivo $FILE está VULNERÁVEL (não imutável)${NC}"
        echo "Correção recomendada:"
        echo "  chattr +i $FILE"
    fi

    echo

done
