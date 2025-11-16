//https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference
provider "google" {
  credentials = file("../google-credentials.json")

  project = "cloud-networking-fundamentals"
  region = "us-central1"
  zone = "us-central1-a"
}

provider "google-beta" {
  credentials = file("../google-credentials.json")

  project = "cloud-networking-fundamentals"
  region = "us-central1"
  zone = "us-central1-a"
}