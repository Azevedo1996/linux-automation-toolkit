# Linux Automation Toolkit

🚀 Toolkit modular para administração Linux, automação, monitoramento, segurança, rede e backup utilizando Rocky Linux 9, Docker e Python.

---

# Sumário

1. Visão Geral
2. Arquitetura
3. Estrutura do Projeto
4. Instalação
5. Inicialização do Ambiente
6. Módulo Diagnostics
7. Módulo Network
8. Módulo Security
9. Módulo Monitoring
10. Configuração do Zabbix
11. Módulo Backup
12. Restauração de Backups
13. Logs
14. Troubleshooting
15. Roadmap
16. Licença

---

# Visão Geral

O Linux Automation Toolkit foi criado para centralizar tarefas operacionais comuns executadas por SysAdmins, Analistas de Infraestrutura, DevOps Engineers e equipes de Monitoramento.

Funcionalidades atuais:

- Diagnóstico de sistema
- Detecção de processos zumbis
- Testes TCP utilizando Netcat
- Auditoria de imutabilidade de arquivos críticos
- Integração AWS → Zabbix
- Backup e restauração
- Execução em Docker Rocky Linux 9

---

# Arquitetura

```text
Windows
 └── Docker Desktop
      └── WSL2
           └── Rocky Linux 9 Container
                ├── Diagnostics
                ├── Network
                ├── Security
                ├── Monitoring
                └── Backup
```

---

# Estrutura do Projeto

```text
linux-automation-toolkit/
├── Dockerfile
├── docker-compose.yml
├── scripts/
│   ├── diagnostics/
│   ├── network/
│   ├── monitoring/
│   ├── security/
│   └── backup/
├── docs/
├── LICENSE
└── README.md
```

---

# Instalação

## Clonar o projeto

```bash
git clone https://github.com/Azevedo1996/linux-automation-toolkit.git
cd linux-automation-toolkit
```

## Construir a imagem

```bash
docker compose build
```

## Iniciar ambiente

```bash
docker compose up -d
```

## Acessar container

```bash
docker exec -it linux-automation-toolkit bash
```

---

# Módulo Diagnostics

## sys_health_check.sh

Coleta:

- CPU
- Memória
- Uptime
- Top 3 partições mais cheias

Execução:

```bash
cd /app/scripts/diagnostics
./sys_health_check.sh
```

Exemplo:

```text
Uso CPU: 15%
Memória usada: 2.1G
Memória livre: 6.2G
Uptime: 5 dias
```

## zombie_hunter.sh

Localiza processos em estado Z.

```bash
./zombie_hunter.sh
```

Fluxo:

```text
Encontrou Zumbi
     ↓
Exibir PID e PPID
     ↓
Perguntar ao administrador
     ↓
kill -9 PPID
```

---

# Módulo Network

## generate_targets.sh

Gera arquivo:

```text
targets.txt
```

Exemplo:

```text
10.18.0.1:80
8.8.8.8:53
1.1.1.1:53
```

## net_port_tester.sh

Testa conectividade TCP.

```bash
./net_port_tester.sh
```

Exemplo:

```text
[SUCCESS] 10.18.0.1:80
[FAILED] 10.18.1.50:10051
```

---

# Módulo Security

## immutable_check.sh

Verifica proteção dos arquivos:

```text
/etc/passwd
/etc/shadow
/etc/group
/etc/gshadow
/etc/sudoers
```

Utiliza:

```bash
lsattr
```

Se não protegido:

```text
[WARNING] Arquivo vulnerável
chattr +i /etc/passwd
```

Execução:

```bash
./immutable_check.sh
```

---

# Módulo Monitoring

## Funcionamento

```text
AWS CloudWatch
      ↓
 boto3
      ↓
aws_metrics_to_zabbix.py
      ↓
zabbix_sender
      ↓
Zabbix Server
```

Execução:

```bash
cd /app/scripts/monitoring
pip3 install -r requirements.txt
python3 aws_metrics_to_zabbix.py
```

---

# Configuração do Zabbix

## Criar Host

```text
Data Collection
Hosts
Create Host
```

Nome:

```text
aws-monitoring-proxy
```

## Criar Item

```text
Type: Zabbix trapper
Key: aws.ec2.cpu.utilization
Type of information: Numeric Float
```

## Ajustar Script

```python
ZABBIX_SERVER = "10.18.0.100"
ZABBIX_HOST = "aws-monitoring-proxy"
ZABBIX_KEY = "aws.ec2.cpu.utilization"
```

## Teste Manual

```bash
zabbix_sender -z 10.18.0.100 \
-s aws-monitoring-proxy \
-k aws.ec2.cpu.utilization \
-o 15.3
```

---

# Módulo Backup

## backup.conf

```bash
SOURCE_DIRS="/etc /home"
BACKUP_DIR="/app/backups/daily"
RETENTION_DAYS=30
```

## Executar Backup

```bash
cd /app/scripts/backup
./backup_manager.sh
```

Exemplo:

```text
[OK] Backup criado
```

## Verificar Integridade

```bash
sha256sum -c arquivo.tar.gz.sha256
```

---

# Restauração de Backups

## Método Interativo

```bash
./restore_backup.sh
```

Exemplo:

```text
1) etc_backup.tar.gz
2) home_backup.tar.gz
```

## Método Manual

```bash
tar -xzf backup.tar.gz -C /
```

## Teste Completo

```bash
mkdir -p /tmp/teste

echo teste > /tmp/teste/arquivo.txt
```

Executar backup.

Remover:

```bash
rm -rf /tmp/teste
```

Restaurar.

Validar:

```bash
cat /tmp/teste/arquivo.txt
```

Resultado:

```text
teste
```

---

# Logs

Monitoramento:

```text
zabbix_integration.log
```

Backup:

```text
backup.log
```

---

# Troubleshooting

## nc não encontrado

```bash
dnf install nmap-ncat
```

## boto3 não encontrado

```bash
pip3 install boto3
```

## zabbix_sender não encontrado

```bash
dnf install zabbix-sender
```

---

# Roadmap de Melhorias

## Versão 1.1

- Backup incremental
- Exclusões configuráveis
- Criptografia GPG
- Relatórios JSON

## Versão 1.2

- Inventário de servidores
- Auditoria de serviços
- Auditoria de portas
- Exportação CSV

## Versão 1.3

- Dashboard Web Flask
- Integração Grafana
- API REST
- Relatórios HTML

## Versão 1.4

- AWS EC2
- AWS RDS
- AWS S3
- Azure Monitor
- OCI Monitor

## Versão 2.0

- Kubernetes
- Docker Management
- Compliance CIS
- Hardening Linux
- Integração Prometheus
- Multiusuário

---

# Código Fonte

Todos os módulos foram escritos em Bash e Python 3.

Principais tecnologias:

- Rocky Linux 9
- Docker
- Bash
- Python 3
- boto3
- Zabbix Sender
- Netcat (nmap-ncat)

---

# Licença

MIT License

---

# Autor

Leonardo Azevedo

GitHub:

https://github.com/Azevedo1996
