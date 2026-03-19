# Create a visual map of the network
mkdir -p network_map
for ip in $hosts; do
    mkdir -p "network_map/Network_Root/$ip"
    # Create sub-folders for open ports to show in the tree
    ports_list=$(nmap -F $ip | grep "open" | awk -F'/' '{print $1}')
    for p in $ports_list; do
        touch "network_map/Network_Root/$ip/Port_$p"
    done
done

echo -e "\n--- VISUAL NETWORK TOPOLOGY ---\n"
tree network_map/Network_Root
rm -rf network_map # Cleanup
