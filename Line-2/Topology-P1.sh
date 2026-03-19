#!/bin/bash

# Configuration: Define your network range or list of IPs
NETWORK_RANGE="192.168.1.0/24"
# Define the temporary data file
DATA_FILE="network_report.tsv"

echo -e "IP\tHOSTNAME\tKERNEL\tACTIVE_USERS\tOPEN_PORTS\tMAC\tNO_PW_USERS\tCRON_JOBS" > $DATA_FILE

echo "Scanning network $NETWORK_RANGE..."

# 1. Discover active hosts
hosts=$(nmap -sn $NETWORK_RANGE | grep "Nmap scan report for" | awk '{print $NF}' | tr -d '()')

for ip in $hosts; do
    echo "Processing $ip..."
    
    # Get Hostname & MAC (Network Level)
    hostname=$(host $ip | awk '{print $NF}' | sed 's/\.$//')
    mac=$(sudo nmap -sP $ip | grep "MAC Address" | awk '{print $3}')
    ports=$(nmap -F $ip | grep "open" | awk '{print $1}' | paste -sd "," -)

    # Get System Info (Requires SSH access - skips if fails)
    # Note: This assumes you have SSH keys set up for the target machines
    sys_info=$(ssh -o ConnectTimeout=2 -q user@$ip "
        kernel=\$(uname -r);
        users=\$(who | wc -l);
        nopass=\$(sudo getent shadow | awk -F: '(\$2 == \"\" || \$2 == \"!\") {print \$1}' | xargs | tr ' ' ',');
        crons=\$(ls /var/spool/cron/crontabs 2>/dev/null | wc -l);
        echo \"\$kernel\t\$users\t\$nopass\t\$crons\"
    " || echo "N/A\tN/A\tN/A\tN/A")

    # Append to table
    echo -e "$ip\t$hostname\t$sys_info\t$ports\t$mac" >> $DATA_FILE
done

# Final Output: Formatting the Table
echo -e "\n--- NETWORK FORENSICS REPORT ---\n"
column -t -s $'\t' $DATA_FILE
