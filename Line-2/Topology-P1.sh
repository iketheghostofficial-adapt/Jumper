#!/bin/bash

# Define your target IPs here
TARGETS=("127.0.0.1" "10.0.2.15")

for IP in "${TARGETS[@]}"; do
    echo "------------------------------------------"
    echo "ENUMERATION REPORT FOR: $IP"
    echo "------------------------------------------"

    # If IP is local, run directly. If remote, wrap in SSH.
    if [[ "$IP" == "127.0.0.1" || "$IP" == "localhost" ]]; then
        CMD_PREFIX=""
    else
        CMD_PREFIX="ssh -q user@$IP"
    fi

    # Execute and Format Output
    $CMD_PREFIX bash -c "
        echo 'IP ADDRESS      - '$IP
        echo 'MAC ADDRESS     - '\$(ip link show | awk '/ether/ {print \$2; exit}')
        echo 'HOSTNAME        - '\$(hostname)
        echo 'KERNEL VERSION  - '\$(uname -r)
        echo 'ACTIVE USERS    - '\$(who | awk '{print \$1}' | sort -u | xargs)
        echo 'INSTALLED SERV. - '\$(dpkg-query -W -f='\${Package}, ' | head -c 50)...
        echo 'RUNNING SERV.   - '\$(systemctl list-units --type=service --state=running --no-legend | awk '{print \$1}' | head -n 5 | xargs)
        echo 'OPEN PORTS      - '\$(ss -tulnp | grep LISTEN | awk '{print \$5}' | cut -d: -f2 | sort -u | xargs)
        echo 'NO PW USERS     - '\$(sudo awk -F: '(\$2 == \"\" || \$2 == \"!\") {print \$1}' /etc/shadow | xargs)
        echo 'CRON JOBS       - '\$(crontab -l 2>/dev/null | grep -v '^#' | xargs || echo 'none')
    "
    echo -e "------------------------------------------\n"
done
