# Module 3: Cloud NAT

This terraform configuration shows a VM with no external IP. We use Google's Cloud NAT to enable NAT'ing so that the VM can communicate
outside of the VPC. 

We use a Cloud Router, which is installed on all VM's in the subnet that the Cloud Router is defined for. There is no actual router/proxy
that does the NAT'ing, VM's are dynamically assigned ports that will be selected to perform the NAT'ing and the Cloud Router is running
within Andromeda, which is running on each VM.