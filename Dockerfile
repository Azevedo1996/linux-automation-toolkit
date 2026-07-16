FROM rockylinux:9

RUN dnf -y update &&     dnf -y install epel-release &&     rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm &&     dnf clean all &&     dnf -y install         python3         python3-pip         nmap-ncat         nmap         curl         iproute         e2fsprogs         zabbix-sender &&     dnf clean all

RUN pip3 install --no-cache-dir boto3 zabbix-api

WORKDIR /app

CMD ["/bin/bash"]
