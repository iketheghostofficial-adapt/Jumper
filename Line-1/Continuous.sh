#!/bin/bash

# Run enhanced Recon.sh against likely targets
for ip in 10.10.10.{1..254}; do
    ./Recon.sh $ip &
done

# Monitor Hackwarz network
watch -n 1 "netstat -tuln | grep LISTEN && arp -a"
