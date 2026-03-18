#!/bin/bash
# Recon Dashboard - Simplified for CTF Speed
# Purpose: Rapid discovery of vulnerable services on the Druida Asteroid network.

TARGET_RANGE=$1
OUTPUT_DIR="./recon_results_$(date +%Y%m%d)"

if [ -z "$TARGET_RANGE" ]; then
    echo "Usage: ./recon.sh <IP_RANGE>"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
echo "--- Starting Reconnaissance on $TARGET_RANGE ---"

# 1. Fast Host Discovery
echo "[*] Scanning for live hosts..."
nmap -sn "$TARGET_RANGE" -oG - | awk '/Up$/{print $2}' > "$OUTPUT_DIR/live_hosts.txt"

# 2. Service Audit on Live Hosts
while read -r host; do
    echo "[!] Auditing Host: $host"
    
    # Check for low-hanging fruit (Web, DB, Remote Access)
    nmap -sV -p 21,22,80,443,445,3306,8080 --script=vuln "$host" > "$OUTPUT_DIR/$host_audit.txt" &
    
    # Grab banners for manual inspection
    (sleep 1; echo "QUIT") | nc -nv "$host" 21 2>&1 | grep "220" >> "$OUTPUT_DIR/banners.txt"
done < "$OUTPUT_DIR/live_hosts.txt"

echo "--- Scan Complete. Results saved to $OUTPUT_DIR ---"
