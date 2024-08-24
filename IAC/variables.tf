variable "my_project" {
    default = "crypto-gantry-431802-r8"
}

variable "region" {
    default = "us-central1"
}

variable "vpc_name" {
    default = "cart-dev-vpc"
}

variable "subnet1_cidr" {
    default = "10.10.0.0/16"
}

variable "ports" {
    default = ["80", "8080", "8081", "9000"]
}

variable "instances" {
    default = {
        "jenkins-master" = {
            type = "e2-medium"
            zone = "us-central1-a"
        }
        "jenkins-slave" = {
            type = "n1-standard-1"
            zone = "us-central1-a"
        }
        "ansible" = {
            type = "e2-medium"
            zone = "us-central1-c"
        }
    }
}