terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

locals {
  prefix = "mod3-vpc-peer-"
  vpcs = ["${local.prefix}vpc-1", "${local.prefix}vpc-2"]
}

resource "google_compute_network" "vpcs" {
    for_each = toset(local.vpcs) 
    name = "${each.value}"
    auto_create_subnetworks = false
}

resource "google_compute_firewall" "fwrules" {
    for_each = toset(local.vpcs)
    name = "${each.value}-fwrule"
    network = google_compute_network.vpcs["${each.value}"].id

    allow {
    protocol  = "tcp"
    ports     = ["22", "1234"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]

}
 
resource "google_compute_subnetwork" "vpc-1-subnet" {
  name = "${local.vpcs[0]}-subnet-a" 
  network = google_compute_network.vpcs["${local.vpcs[0]}"].id
  region = "us-central1"
  ip_cidr_range = "10.0.0.0/24"
}

resource "google_compute_subnetwork" "vpc-2-subnet" {
    name = "${local.vpcs[1]}-subnet-a"
    network = google_compute_network.vpcs["${local.vpcs[1]}"].id
    region = "us-east1"
    ip_cidr_range = "10.0.1.0/24"
}

resource "google_compute_instance" "vm1" {
    name = "${local.vpcs[0]}-vm"
    machine_type = "e2-micro"
    zone = "us-central1-a"
    network_interface {
        network = google_compute_network.vpcs["${local.vpcs[0]}"].id
        subnetwork = google_compute_subnetwork.vpc-1-subnet.id
        access_config {
          network_tier = "STANDARD"
        }
    }
    boot_disk {
        initialize_params {
            image = "debian-12-bookworm-v20240312"
        }
    }
    metadata = {
        startup-script = "sudo apt update; sudo apt -y install netcat-traditional ncat;"
    }
}

resource "google_compute_instance" "vm2" {
    name = "${local.vpcs[1]}-vm"
    machine_type = "e2-micro"
    zone = "us-east1-b"
    network_interface {
        network = google_compute_network.vpcs["${local.vpcs[1]}"].id
        subnetwork = google_compute_subnetwork.vpc-2-subnet.id
    }
    boot_disk {
        initialize_params {
            image = "debian-12-bookworm-v20240312"
        }
    }
    metadata = {
        startup-script = "sudo apt update; sudo apt -y install netcat-traditional ncat;"
    }
}

resource "google_compute_network_peering" "vpc-1-to-vpc-2" {
 name = "vpc-1-to-vpc-2-peering" 
 network = google_compute_network.vpcs["${local.vpcs[0]}"].id
 peer_network =google_compute_network.vpcs["${local.vpcs[1]}"].id 
}

resource "google_compute_network_peering" "vpc-2-to-vpc-1" {
 name = "vpc-2-to-vpc-1-peering" 
 network = google_compute_network.vpcs["${local.vpcs[1]}"].id
 peer_network =google_compute_network.vpcs["${local.vpcs[0]}"].id 
}