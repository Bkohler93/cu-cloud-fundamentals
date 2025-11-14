# Module 3: VPC Peering

This terraform configuration sets up two VPCs in different regions, then configures two VMs to be able
to communicate with each other.

After running `terraform apply` SSH'ing into vm1 will work and vm1 is able to ping vm2 via it's internal IP address.