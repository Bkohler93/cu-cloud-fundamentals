# Module 3: Lab

This lab combines GCP's Cloud NAT and VPC Peering to setup two VM's in different VPCs/regions, setting up Cloud NAT in one of the
VPC's and allowing the other VPC/VM to reach the public internet via VPC Peering. This lab allows VM1 to reach neverssl.com (ip 34.223.124.45) via VM2. 

This may be a setup if you want internal machine to be able to talk to an external machine, but only that external machine.

In order for traffic to be forwarded, this lab also uses tunneling (VXLan) to forward traffic from one VM to the other.

The scripts `vm1-startup.sh` and `vm2-startup.sh` show how to create the vxlan, setup ipv4 forwarding, and setup NAT match/action rules.

[infrastructure setup](./infra.png)
[vxlan tunnel setup](./vxlan.png)

After applying the terraform configuration, VM1 can run `wget 34.223.142.45` and reach neverssl.com, demonstrating how an internal machine can reach the public internet.