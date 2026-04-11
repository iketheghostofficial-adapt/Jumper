#!/bin/bash

TARGET=$1
JUMPER_IP=$(hostname -I | awk '{print $1}')

echo "[+] Jumpbox Recon: $TARGET from $JUMPER_IP"

# Stealth TCP SYN scan (avoids -sS which requires root)
nmap -sS -T4 --min-rate 1000 -p- -oN recon-$TARGET.nmap $TARGET

# UDP + service version + scripts
nmap -sUV --script vuln -T4 -oN service-$TARGET.nmap $TARGET

# Web stack fingerprint
gobuster dir -u http://$TARGET -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php,asp,aspx,jsp,html,js,css -t 50 -o web-$TARGET.txt 2>/dev/null &
gobuster dns -d $TARGET -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt -t 50 -o dns-$TARGET.txt 2>/dev/null &

# SMB/Win enum
enum4linux -a $TARGET > smb-$TARGET.txt 2>/dev/null || echo "[!] enum4linux failed"

wait
cat *.txt > full-recon-$TARGET.txt
echo "[+] Full recon complete: full-recon-$TARGET.txt"
