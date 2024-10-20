## Create a vpc
resource "google_compute_network" "tf_vpc" {
    name = var.vpcname
    auto_create_subnetworks = false
}

## Create subnet in us-central1
resource "google_compute_subnetwork" "tf_subnet1" {
    name = "${var.vpcname}-subnet1"
    network = google_compute_network.tf_vpc.name
    region = var.region
    ip_cidr_range = var.subnet_cidr
}

resource "google_compute_subnetwork" "tf_subnet2" {
    name = "${var.vpcname}-subnet2"
    network = google_compute_network.tf_vpc.name
    region = "us-west1"
    ip_cidr_range = "10.2.0.0/16"
}

## Create firewall-rule
resource "google_compute_firewall" "tf_firewall1" {
    name = "${var.vpcname}-firewall1"
    network = google_compute_network.tf_vpc.name
    direction = "INGRESS"
    description = "This firewall allows traffic from tcp ports 22, 80, 443, 8080, 8081, 9000"
    # allow {
    #     protocol = "tcp"
    #     ports    = ["22", "80", "443", "8080", "8081", "9000"]
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

## Create a Key-Pair
resource "tls_private_key" "tf_keypair" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

## Store Private key locally
resource "local_file" "ssh_privatekey" {
    content = tls_private_key.tf_keypair.private_key_pem
    # filename = "/c/Users/kasas/Desktop/project/IAC/id_rsa"
    filename = "${path.module}/id_rsa"
}

## Store Public key locally
resource "local_file" "ssh_publickey" {
    content = tls_private_key.tf_keypair.public_key_openssh
    filename = "${path.module}/id_rsa.pub"
}

## Create 3 VMs
resource "google_compute_instance" "tf_instance" {
    for_each = var.instances
    name = each.key
    machine_type = each.value.machine
    zone = each.value.zone
    tags = [each.key]
    boot_disk {
        auto_delete = true
        device_name = each.key
        mode = "READ_WRITE"
        initialize_params {
            size = 10
            type = "pd-balanced"
            # image = "projects/${var.projectid}/global/images/ubuntu-2004-focal-v20240830"
            image = data.google_compute_image.tf_image.self_link
            labels = {
                name = each.key
            }
        }
    }
    network_interface {
        network = google_compute_network.tf_vpc.name
        # subnetwork = google_compute_subnetwork.tf_subnet1.name
        subnetwork = each.key == "sonarqube" ? google_compute_subnetwork.tf_subnet2.name : google_compute_subnetwork.tf_subnet1.name
        stack_type = "IPV4_ONLY"
        access_config {
            network_tier = "PREMIUM"
        }
    }
    metadata = {
        ssh-keys = "${var.username}:${tls_private_key.tf_keypair.public_key_openssh}"
    }
    connection {
        type = "ssh"
        user = var.username
        host = self.network_interface[0].access_config[0].nat_ip
        # private_key = file("id_rsa")
        # We need to generate a key pair locally. 
        # Public key to be placed in project metadata section
        # Private key to be placed in current working directory with id_rsa name
        private_key = tls_private_key.tf_keypair.private_key_pem
    }
    provisioner "file" {
        source = each.key == "ansible-controller" ? "ansible.sh" : "other.sh"
        destination = each.key == "ansible-controller" ? "/home/${var.username}/ansible.sh" : "/home/${var.username}/other.sh"
    }
    provisioner "remote-exec" {
        inline = [
            each.key == "ansible-controller" ? "chmod +x /home/${var.username}/ansible.sh && sh /home/${var.username}/ansible.sh" : "echo 'Skip the execution!!'"
        ]
    }
    provisioner "file" {
        source = "${path.module}/id_rsa"
        destination = "/home/${var.username}/id_rsa"
    }
}

## compute image
data "google_compute_image" "tf_image" {
    family = "ubuntu-2004-lts"
    project = "ubuntu-os-cloud"
}