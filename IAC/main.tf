# Create a VPC
resource "google_compute_network" "my_vpc" {
    project = var.my_project
    name = var.vpc_name
    auto_create_subnetworks = false
}

# Create subnetwork-1
resource "google_compute_subnetwork" "my-subnet1" {
    name = "${var.vpc_name}-subnet1"
    network = google_compute_network.my_vpc.name
    region = var.region
    ip_cidr_range = var.subnet1_cidr
}

# Create firewall to allow Traffic
resource "google_compute_firewall" "my_firewall" {
    network = google_compute_network.my_vpc.name
    name = "${var.vpc_name}-firewall"
    description = "Allow the traffic from respective ports"
    # allow {
    #     protocol = "tcp"
    #     ports = ["8080", "80", "8081", "9000"]
    # }
    dynamic "allow" {
        for_each = var.ports
        content {
            protocol = "tcp"
            ports = [allow.value]
        }
    }
    source_ranges = ["0.0.0.0/0"]
}

# Create compute instances
resource "google_compute_instance" "my_instance" {
    for_each = var.instances
    name = each.key
    machine_type = each.value.type
    zone = each.value.zone
    tags = [each.key]
    network_interface {
        network = google_compute_network.my_vpc.name
        subnetwork = google_compute_subnetwork.my-subnet1.name
        stack_type = "IPV4_ONLY"
        access_config {
            network_tier = "PREMIUM"
        }
    }
    boot_disk {
        auto_delete = true
        mode = "READ_WRITE"
        initialize_params {
            size = 10
            type = "pd-ssd"
            image = data.google_compute_image.my_image.self_link
            # image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240808"
            labels = {
                name = each.key
            }
        }
    }
}

# Data block to get the image
data "google_compute_image" "my_image" {
    family = "ubuntu-2004-lts"
    project = "ubuntu-os-cloud"
}