#!/bin/bash
set -e

echo "Hello from startup script!" >> /tmp/startup_log.txt

#this VM has access to internet via Cloud NAT/cloud Router
sudo apt update -y
sudo apt install -y netcat-traditional ncat iptables

# Enable IPv4 forwarding
sudo sed -i '/^#*net.ipv4.ip_forward/c\net.ipv4.ip_forward=1' /etc/sysctl.conf
sudo sysctl -w net.ipv4.ip_forward=1

# create vxlan
sudo ip link add vxlan0 type vxlan id 5001 remote 172.16.0.2 local 172.16.1.2 dev ens4 dstport 50000
sudo ip addr add 192.168.100.3/24 dev vxlan0
sudo ip link set up dev vxlan0

# add NATing for traffic from vxlan
sudo iptables -t nat -A POSTROUTING -s 192.168.0.0/16 -o ens4 -j MASQUERADE