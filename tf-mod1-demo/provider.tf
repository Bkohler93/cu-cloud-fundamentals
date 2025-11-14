provider "google" {
  credentials = file("../google-credentials.json")

  project = "cloud-networking-fundamentals"
  region  = "us-central1"  // default
  zone    = "us-central1-a"  // default
}
