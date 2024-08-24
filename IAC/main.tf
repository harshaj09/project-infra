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