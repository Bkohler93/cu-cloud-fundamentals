provider "google" {
  credentials = file("../google-credentials.json")

  project = "cloud-networking-fundamentals"
}