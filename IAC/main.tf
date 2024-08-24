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