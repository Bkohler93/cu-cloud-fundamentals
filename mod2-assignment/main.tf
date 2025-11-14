terraform {
    required_providers {
      google = {
        source = "hashicorp/google"
        version = "4.51.0"
      }
    }
}

locals {
  project = "cloud-networking-fundamentals"
  prefix = "tf-mod2-lab1-"
}

# create VPCs
resource "google_compute_network" "tf-mod2-lab1-vpc1" {
    name = "${local.prefix}vpc1" 
}


resource "google_compute_network" "tf-mod2-lab1-vpc2" {
    name = "${local.prefix}vpc2" 
}

# firewalls for vpc1
resource "google_compute_firewall" "tf-mod2-lab1-fwrule1" {
    project = "${local.project}"
    name = "${local.prefix}fwrule1"
    network = google_compute_network.tf-mod2-lab1-vpc1.id

    allow {
      protocol = "tcp"
      ports = ["22", "1234"]
    }
    allow {
      protocol = "icmp"
    }
    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "tf-mod2-lab1-fwrule2" {
    project = "${local.project}"
    name = "${local.prefix}fwrule2"
    network = google_compute_network.tf-mod2-lab1-vpc2.id

    allow {
      protocol = "tcp"
      ports = ["22", "1234"]
    }
    allow {
      protocol = "icmp"
    }
    source_ranges = ["0.0.0.0/0"]
}

# subnet for vpc1
resource "google_compute_subnetwork" "tf-mod2-lab1-sub1" {
    name = "${local.prefix}sub1"
    network = google_compute_network.tf-mod2-lab1-vpc1.id
    region = "us-central1"
    ip_cidr_range = "10.0.1.0/24"
}

# VM for sub1
resource "google_compute_instance" "tf-mod2-lab1-vm1" {
    name = "${local.prefix}vm1"
    machine_type = "e2-micro"
    zone = "us-central1-a"
    network_interface {
      access_config {
        network_tier = "STANDARD"
      }
      network = google_compute_network.tf-mod2-lab1-vpc1.id
      subnetwork = google_compute_subnetwork.tf-mod2-lab1-sub1.id
    }
    boot_disk {
      initialize_params {
        image = "debian-12-bookworm-v20240312"
      }
    }
    metadata = { 
        startup-script = "sudo apt update; sudo apt install -y netcat-traditional ncat;" 
    }
}

# subnets for vpc2
resource "google_compute_subnetwork" "tf-mod2-lab1-sub2" {
    name = "${local.prefix}sub2"
    network = google_compute_network.tf-mod2-lab1-vpc2.id
    region = "us-central1"
    ip_cidr_range = "10.0.2.0/24"
}

# VMs for sub2
resource "google_compute_instance" "tf-mod2-lab1-vm2" {
    name = "${local.prefix}vm2"
    machine_type = "e2-micro"
    zone = "us-central1-a"
    network_interface {
      access_config {
        network_tier = "STANDARD"
      }
      network = google_compute_network.tf-mod2-lab1-vpc2.id
      subnetwork = google_compute_subnetwork.tf-mod2-lab1-sub2.id
    }
    boot_disk {
      initialize_params {
        image = "debian-12-bookworm-v20240312"
      }
    }
    metadata = { 
        startup-script = "sudo apt update; sudo apt install -y netcat-traditional ncat;" 
    }
}

resource "google_compute_instance" "tf-mod2-lab1-vm3" {
    name = "${local.prefix}vm3"
    machine_type = "e2-micro"
    zone = "us-central1-a"
    network_interface {
      access_config {
        network_tier = "STANDARD"
      }
      network = google_compute_network.tf-mod2-lab1-vpc2.id
      subnetwork = google_compute_subnetwork.tf-mod2-lab1-sub2.id
    }
    boot_disk {
      initialize_params {
        image = "debian-12-bookworm-v20240312"
      }
    }
    metadata = { 
        startup-script = "sudo apt update; sudo apt install -y netcat-traditional ncat;" 
    }
}

resource "google_compute_subnetwork" "tf-mod2-lab1-sub3" {
    name = "${local.prefix}sub3"
    network = google_compute_network.tf-mod2-lab1-vpc2.id
    region = "us-central1"
    ip_cidr_range = "10.0.3.0/24"
}

# VM for sub3
resource "google_compute_instance" "tf-mod2-lab1-vm4" {
    name = "${local.prefix}vm4"
    machine_type = "e2-micro"
    zone = "us-central1-a"
    network_interface {
      access_config {
        network_tier = "STANDARD"
      }
      network = google_compute_network.tf-mod2-lab1-vpc2.id
      subnetwork = google_compute_subnetwork.tf-mod2-lab1-sub3.id
    }
    boot_disk {
      initialize_params {
        image = "debian-12-bookworm-v20240312"
      }
    }
    metadata = { 
        startup-script = "sudo apt update; sudo apt install -y netcat-traditional ncat;" 
    }
}