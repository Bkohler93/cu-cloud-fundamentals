# Module 4 Lab: Setup A - Unmanaged Regional ALB to Unmanaged Regional NLB

The infrastructure for this lab example uses a regional, external load balancer to direct user traffic to one of two frontend servers. 
The frontend servers receive data from backend servers, with traffic managed by a network load balancer. Backend servers use a 
Postgres database to store/update a total hit count for the service. 

Frontend and backend application are written in Go, built into binaries and stored on. A NAT gateway allows all servers to have 
internet access.

Architecture can be seen in [architecture](./architecture.png)