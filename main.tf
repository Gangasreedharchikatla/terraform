terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
  backend "gcs" {
   bucket  = "sreedhar"
   prefix  = "terraform/state"
  }
}

provider "google" {
 //credentials = file("credentials.json")


  project = "gangasreedharchikatla-prj"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "testterraform-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
  
}

resource "google_service_account" "default" {
  account_id   = "sa-terraform"
  display_name = "Custom SA for VM Instance"
}

resource "google_compute_instance" "default" {
  name         = "my-terraform-test"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"

  tags = ["terraform", "test"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = google_compute_network.vpc_network.id
   // subnetwork = google_compute_subnetwork.testterraform-subnetwork.id
  subnetwork = google_compute_subnetwork.subnet.id
    
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "none"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}
