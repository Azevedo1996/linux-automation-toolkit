#!/bin/bash

cat > backup.conf << 'EOF'
SOURCE_DIRS="/etc /home"
BACKUP_DIR="/app/backups/daily"
RETENTION_DAYS=30
EOF

echo "backup.conf criado com sucesso."
