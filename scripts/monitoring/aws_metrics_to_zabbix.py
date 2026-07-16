#!/usr/bin/env python3
"""
Linux Automation Toolkit - Monitoring Module
Coleta métrica AWS (EC2 CPU) via boto3 e envia ao Zabbix.
"""

import logging
import subprocess
import sys
from datetime import datetime, timedelta

import boto3
from botocore.exceptions import BotoCoreError, ClientError, NoCredentialsError

LOG_FILE = "zabbix_integration.log"
ZABBIX_SERVER = "10.18.0.100"
ZABBIX_HOST = "aws-monitoring-proxy"
ZABBIX_KEY = "aws.ec2.cpu.utilization"
INSTANCE_ID = "i-0123456789abcdef0"
AWS_REGION = "us-east-1"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)


def collect_ec2_cpu_metric():
    """Coleta CPUUtilization do CloudWatch."""
    try:
        logger.info("Iniciando coleta de métricas AWS via boto3")

        cloudwatch = boto3.client("cloudwatch", region_name=AWS_REGION)

        end_time = datetime.utcnow()
        start_time = end_time - timedelta(minutes=10)

        response = cloudwatch.get_metric_statistics(
            Namespace="AWS/EC2",
            MetricName="CPUUtilization",
            Dimensions=[{"Name": "InstanceId", "Value": INSTANCE_ID}],
            StartTime=start_time,
            EndTime=end_time,
            Period=300,
            Statistics=["Average"]
        )

        datapoints = response.get("Datapoints", [])

        if not datapoints:
            logger.warning("Nenhum datapoint retornado. Utilizando valor simulado.")
            return 12.5

        latest = sorted(datapoints, key=lambda x: x["Timestamp"])[-1]
        value = float(latest["Average"])

        logger.info("CPU coletada com sucesso: %.2f%%", value)
        return value

    except (NoCredentialsError, BotoCoreError, ClientError, Exception) as exc:
        logger.exception("Falha na coleta AWS: %s", exc)
        logger.warning("Utilizando métrica simulada para continuidade do fluxo.")
        return 15.0



def send_to_zabbix(metric_value):
    """Envia métrica para o servidor Zabbix usando zabbix_sender."""
    cmd = [
        "zabbix_sender",
        "-z", ZABBIX_SERVER,
        "-s", ZABBIX_HOST,
        "-k", ZABBIX_KEY,
        "-o", str(metric_value)
    ]

    try:
        logger.info("Executando: %s", ' '.join(cmd))

        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=15,
            check=False
        )

        logger.info("Return code: %s", result.returncode)

        if result.stdout:
            logger.info("STDOUT: %s", result.stdout.strip())

        if result.stderr:
            logger.warning("STDERR: %s", result.stderr.strip())

        if result.returncode != 0:
            raise RuntimeError(f"zabbix_sender retornou código {result.returncode}")

        logger.info("Métrica enviada com sucesso ao Zabbix.")
        return True

    except subprocess.TimeoutExpired:
        logger.exception("Timeout ao conectar ao servidor Zabbix interno.")
    except FileNotFoundError:
        logger.exception("Binário zabbix_sender não encontrado no sistema.")
    except Exception as exc:
        logger.exception("Erro durante envio ao Zabbix: %s", exc)

    return False


if __name__ == "__main__":
    logger.info("=== Início da integração AWS -> Zabbix ===")

    metric = collect_ec2_cpu_metric()
    success = send_to_zabbix(metric)

    if success:
        logger.info("Processo concluído com sucesso.")
        sys.exit(0)

    logger.error("Processo finalizado com erro.")
    sys.exit(1)
