# Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# VPC Networks
resource "google_compute_network" "wordpress_vpc" {
  name                    = "wordpress-vpc"
  auto_create_subnetworks = false
  description             = "VPC for WordPress deployment"
}

# Subnet VPC
resource "google_compute_subnetwork" "wordpress_subnet" {
  name          = "wordpress-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.wordpress_vpc.id
  description   = "Public subnet for WordPress VM"
}

# Firewall Rules
resource "google_compute_firewall" "wordpress_firewall" {
  name    = "wordpress-firewall"
  network = google_compute_network.wordpress_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["wordpress-server"]
  
  description = "Allow SSH and WordPress access"
}

# Startup Script
locals {
  startup_script = <<-EOF
    #!/bin/bash
    
    # Update system
    apt-get update
    apt-get upgrade -y
    
    # Install Docker
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
    
    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # Add user to docker group
    usermod -aG docker $USER
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    # Create app directory
    mkdir -p /home/wordpress-app
    cd /home/wordpress-app
    
    # Create docker-compose.yml
    cat > docker-compose.yml << 'COMPOSE_EOF'
version: '3.8'

services:
  db:
    image: mysql:5.7
    container_name: wordpress_db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${var.mysql_root_password}
      MYSQL_DATABASE: ${var.mysql_database}
      MYSQL_USER: ${var.mysql_user}
      MYSQL_PASSWORD: ${var.mysql_password}
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - wordpress_network

  wordpress:
    image: wordpress:latest
    container_name: wordpress_app
    restart: unless-stopped
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_NAME: ${var.mysql_database}
      WORDPRESS_DB_USER: ${var.mysql_user}
      WORDPRESS_DB_PASSWORD: ${var.mysql_password}
    volumes:
      - wordpress_data:/var/www/html
    depends_on:
      - db
    networks:
      - wordpress_network

volumes:
  db_data:
  wordpress_data:

networks:
  wordpress_network:
    driver: bridge
COMPOSE_EOF
    
    docker-compose up -d
    
    echo "WordPress deployment completed at $(date)" >> /var/log/startup-script.log
  EOF
}

# VM Instance 
resource "google_compute_instance" "wordpress_vm" {
  name         = "wordpress-vm"
  machine_type = "e2-micro"
  zone         = var.zone
  tags         = ["wordpress-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.wordpress_vpc.id
    subnetwork = google_compute_subnetwork.wordpress_subnet.id
    
    access_config {
      
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  metadata_startup_script = local.startup_script

  service_account {
    scopes = ["cloud-platform"]
  }

  labels = {
    environment = "test"
    project     = "wordpress"
  }
}