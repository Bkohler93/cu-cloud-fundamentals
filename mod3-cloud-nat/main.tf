terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

resource "google_compute_network" "vpc" {
    name = "mod3-cloud-nat-vpc"
    auto_create_subnetworks = false
}

resource "google_compute_firewall" "fwrule" {
    name = "mod3-cloud-nat-fwrule"
    network = google_compute_network.vpc.id

    allow {
    protocol  = "tcp"
    ports     = ["22", "1234"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]

}
 
resource "google_compute_subnetwork" "vpc-subnet" {
  name = "mod3-cloud-nat-subnet-a" 
  network = google_compute_network.vpc.id
  region = "us-central1"
  ip_cidr_range = "10.0.0.0/24"
}

resource "google_compute_instance" "vm1" {
    name = "mod3-cloud-nat-vm"
    machine_type = "e2-micro"
    zone = "us-central1-a"
    network_interface {
        network = google_compute_network.vpc.id
        subnetwork = google_compute_subnetwork.vpc-subnet.id
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

resource "google_compute_router" "rtr" {
    name = "mod3-cloud-nat-rtr"
    network = google_compute_network.vpc.id
    region = google_compute_subnetwork.vpc-subnet.region

    bgp {
      asn = 64514
    }
}

resource "google_compute_router_nat" "rtr-nat" {
    name = "mod3-cloud-nat-rtr-nat"
    nat_ip_allocate_option = "AUTO_ONLY"
    router = google_compute_router.rtr.name
    region = google_compute_router.rtr.region
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

    log_config {
      enable = true
      filter = "ERRORS_ONLY"
    }
}