
provider "google" {
  credentials = file("csec5615-bfe07a47c9ea.json")
  project = "csec5615"          #my own GCP account project id
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_instance" "cowrie_gcp" {
  name         = "cowrie-gcp"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("cowrie-setup.sh")
  tags = ["cowrie"]
}

resource "google_compute_firewall" "cowrie_fw" {
  name    = "allow-cowrie"
  network = "default"

  allow {
  protocol = "tcp"
  ports    = ["2222"]  # Admin SSH
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "23"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["cowrie"]
}
