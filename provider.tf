terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.22.0"
    }
  }
}
provider "google" {
  project     = "secure-granite-397514"
  region      = "us-west1"
  zone        = "us-west1-b"
  credentials = 
}