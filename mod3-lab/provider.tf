//https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference
provider "google" {
  credentials = file("../google-credentials.json")

  project = "cloud-networking-fundamentals"
}