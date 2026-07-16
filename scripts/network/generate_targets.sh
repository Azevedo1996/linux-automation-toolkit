#!/bin/bash

# Gera um arquivo targets.txt com exemplos para testes

cat > targets.txt << 'EOF'
10.18.0.1:80
10.18.1.50:10051
192.168.1.1:443
8.8.8.8:53
1.1.1.1:53
142.250.191.78:443
EOF

echo "Arquivo targets.txt criado com sucesso."
