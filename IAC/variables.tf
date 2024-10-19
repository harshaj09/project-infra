variable "projectid" {
    default = "crypto-gantry-431802-r8"
}

variable "region" {
    default = "us-central1"
}

variable "vpcname" {
    default = "dev-network"
}

variable "subnet_cidr" {
    default = "10.1.0.0/16"
}

variable "ports" {
    default = ["22", "80", "443", "8080", "8081", "9000"]
}

variable "instances" {
    default = {
        jenkins-master = {
            machine = "e2-medium"
            zone = "us-central1-c"
        }
        jenkins-slave = {
            machine = "n1-standard-1"
            zone = "us-central1-c"
        }
        ansible-controller = {
            machine = "e2-medium"
            zone = "us-central1-c"
        }
    }
}

variable "username" {
    default = "padmajaganji111"
}