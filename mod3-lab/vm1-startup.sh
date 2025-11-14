#!/bin/bash
set -e

echo "Hello from startup script!" >> /tmp/startup_log.txt

# create vxlan 
sudo ip link add vxlan0 type vxlan id 5001 local 172.16.0.2 remote 172.16.1.2 dev ens4 dstport 50000
sudo ip addr add 192.168.100.2/24 dev vxlan0
sudo ip link set up dev vxlan0

# set up route to neverssl.com's ip address
sudo ip route add 34.223.124.45/32 via 192.168.100.3
