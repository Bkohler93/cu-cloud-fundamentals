terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

locals {
  prefix = "mod3-lab-"
}

resource "google_compute_network" "vpc1" {
    name = "${local.prefix}vpc1"
    auto_create_subnetworks = false
}

resource "google_compute_firewall" "fwrule1" {
    name = "${local.prefix}fwrule1"
    network = google_compute_network.vpc1.name
    allow {
        protocol = "icmp"
    }
    allow {
      protocol = "tcp"
      ports = [ "22", "1234" ]
    }
    allow {
      protocol = "udp"
      ports = ["50000"]
    }
    source_ranges = [ "0.0.0.0/0" ]
}

resource "google_compute_subnetwork" "sub1" {
    name = "${local.prefix}sub1"
    ip_cidr_range = "172.16.0.0/24"
    network = google_compute_network.vpc1.name
    region = "us-central1"
}

resource "google_compute_instance" "vm1" {
    name = "${local.prefix}vm1"
    machine_type = "e2-micro"
    zone = "us-central1-a"
    network_interface {
      network = google_compute_network.vpc1.name
      subnetwork = google_compute_subnetwork.sub1.name
      network_ip = google_compute_address.vm1-internal-address.address
    }
    
    boot_disk {
        initialize_params {
            image = "debian-12-bookworm-v20240312"
        }
    }
    metadata_startup_script = file("${path.module}/vm1-startup.sh")
}

resource "google_compute_address" "vm1-internal-address" {
    name = "${local.prefix}vm1-internal-address"
    subnetwork = google_compute_subnetwork.sub1.id
    address = "172.16.0.2"
    address_type = "INTERNAL"
    region = "us-central1"
}


resource "google_compute_network" "vpc2" {
    name = "${local.prefix}vpc2"
    auto_create_subnetworks = false
}

resource "google_compute_firewall" "fwrule2" {
    name = "${local.prefix}fwrule2"
    network = google_compute_network.vpc2.name
    allow {
      protocol = "icmp"
    }
    allow {
      protocol = "tcp"
      ports = [ "22", "1234" ]
    }
    allow {
      protocol = "udp"
      ports = ["50000"]
    }
    source_ranges = [ "0.0.0.0/0" ]
}

resource "google_compute_subnetwork" "sub2" {
    network = google_compute_network.vpc2.name
    name = "${local.prefix}sub2"
    ip_cidr_range = "172.16.1.0/24"
    region = "us-east1"
}

resource "google_compute_router" "rtr" {
    region = "us-east1"
    name = "${local.prefix}vpc2-rtr"
    network = google_compute_network.vpc2.name
}

resource "google_compute_router_nat" "nat" {
    region = "us-east1"
    name = "${local.prefix}vpc2-rtr-nat"
    router = google_compute_router.rtr.name
    nat_ip_allocate_option = "AUTO_ONLY"
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_instance" "vm2" {
    name = "${local.prefix}vm2"
    machine_type = "e2-micro"
    zone = "us-east1-b"
    network_interface {
      network = google_compute_network.vpc2.name
      subnetwork = google_compute_subnetwork.sub2.name
      network_ip =google_compute_address.vm2-internal-address.address 
    }
    boot_disk {
        initialize_params {
            image = "debian-12-bookworm-v20240312"
        }
    }
    metadata_startup_script = file("${path.module}/vm2-startup.sh") 
}


resource "google_compute_address" "vm2-internal-address" {
    region = "us-east1"
    name = "${local.prefix}vm1-internal-address"
    subnetwork = google_compute_subnetwork.sub2.id
    address = "172.16.1.2"
    address_type = "INTERNAL"
}

resource "google_compute_network_peering" "vpc1-to-vpc2" {
    name = "${local.prefix}-peering-vpc1-to-vpc2"
    network = google_compute_network.vpc1.id
    peer_network = google_compute_network.vpc2.id
}

resource "google_compute_network_peering" "vpc2-to-vpc1" {
    name = "${local.prefix}-peering-vpc2-to-vpc1"
    network = google_compute_network.vpc2.id
    peer_network = google_compute_network.vpc1.id
}