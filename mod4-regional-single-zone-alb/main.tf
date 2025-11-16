locals {
  prefix = "mod4-regional-single-zone-alb-"
}

# VPC
resource "google_compute_network" "default" {
  name                    = "${local.prefix}vpc"
  auto_create_subnetworks = false
}

# backend subnet
resource "google_compute_subnetwork" "default" {
  name          = "${local.prefix}vpc-sub"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.default.id
}

resource "google_compute_subnetwork" "proxy" {
    name = "${local.prefix}proxy-subnet"
    ip_cidr_range = "10.0.2.0/24"
    region = "us-central1"
    network = google_compute_network.default.id

    purpose = "REGIONAL_MANAGED_PROXY"
    role    = "ACTIVE"
}

# reserved IP address
resource "google_compute_address" "default" {
  provider = google
  name     = "${local.prefix}ip-addr"
}

# forwarding rule
resource "google_compute_forwarding_rule" "default" {
  name                  = "${local.prefix}forwarding-rule"
  region = "us-central1"
  provider              = google
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.default.id
  ip_address            = google_compute_address.default.id
  network = google_compute_network.default.id

  depends_on = [ google_compute_subnetwork.proxy ]
}

# http proxy
resource "google_compute_region_target_http_proxy" "default" {
  name     = "${local.prefix}http-proxy"
  provider = google
  url_map  = google_compute_region_url_map.default.id
  region = "us-central1"
}

# url map
resource "google_compute_region_url_map" "default" {
  name            = "${local.prefix}url-map"
  provider        = google
  default_service = google_compute_region_backend_service.default.id
  region = "us-central1"
}

# backend service with custom request and response headers
resource "google_compute_region_backend_service" "default" {
  name                    = "${local.prefix}backend-service"
  region                    = "us-central1"
  provider                = google
  protocol                = "HTTP"
  port_name               = "http"
  load_balancing_scheme   = "EXTERNAL_MANAGED"
  timeout_sec             = 10
  health_checks           = [google_compute_region_health_check.default.id]
  backend {
    capacity_scaler = 1.0
    group           = google_compute_instance_group_manager.default.instance_group
    balancing_mode  = "UTILIZATION"
  }
}

# instance template
resource "google_compute_instance_template" "default" {
  name         = "${local.prefix}instance-template"
  provider     = google
  machine_type = "e2-small"
  tags         = ["allow-health-check"]

  network_interface {
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.default.id
  }
  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  # install nginx and serve a simple web page
  metadata = {
    startup-script = <<-EOF1
      #! /bin/bash
      set -euo pipefail

      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y nginx-light jq

      NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')

      cat <<EOF > /var/www/html/index.html
      <pre>
      Name: $NAME
      IP: $IP
      Metadata: $METADATA
      sup
      </pre>
      EOF
    EOF1
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_router" "default" {
    name = "${local.prefix}rtr"
    network = google_compute_network.default.id
    region = google_compute_subnetwork.default.region
    
    bgp {
      asn = 64514
    }
}

resource "google_compute_router_nat" "default" {
    name = "${local.prefix}cloud-nat"
    nat_ip_allocate_option = "AUTO_ONLY"
    router = google_compute_router.default.name
    region = google_compute_router.default.region
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_region_health_check" "default" {
  name     = "${local.prefix}health-check"

    http_health_check {
      port_specification = "USE_NAMED_PORT"
      port_name = "http"
    }
}


# MIG
resource "google_compute_instance_group_manager" "default" {
  name     = "${local.prefix}igm"
  provider = google
  zone = "us-central1-a"
  named_port {
    name = "http"
    port = 80
  }
  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 3
}

# allow access from health check ranges
resource "google_compute_firewall" "default" {
  name          = "${local.prefix}fwrule-hc"
  provider      = google
  direction     = "INGRESS"
  network       = google_compute_network.default.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "10.0.2.0/24"]
  allow {
    protocol = "tcp"
    ports = [ "80" ]
  }
  target_tags = ["allow-health-check"]
}

resource "google_compute_firewall" "ssh" {
    name = "${local.prefix}fwrule-ssh"
    network = google_compute_network.default.id
    destination_ranges = [ "10.0.1.0/24" ]
    allow {
      protocol = "tcp"
      ports = ["22"]
    }
    source_ranges =  [ "0.0.0.0/0"]
}