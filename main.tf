resource "google_compute_address" "static_address" {
    name = "ipv4-cicd-test"
    region = "us-west1"
}

resource "google_compute_instance" "web-server" {
  name         = "cit262-vm-cicd"
  project      = "secure-granite-397514"        //change this
  machine_type = "e2-medium"
  zone         = "us-west1-b"
  tags         = ["http-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static_address.address
    }
  }
  metadata_startup_script = <<-SCRIPT
    #!/bin/bash
    sudo apt-get update 
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    sleep 5
    # Add the repository to Apt sources:
    echo \
        'deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo '$VERSION_CODENAME') stable' | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sleep 10
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sleep 30
    sudo docker build https://github.com/dockersamples/node-bulletin-board.git#master:bulletin-board-app
    sleep 30
    dockerimage =$(docker images -q)
    sudo docker run -p 80:8080 $dockerimage
  SCRIPT
}