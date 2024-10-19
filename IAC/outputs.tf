# output "jenkins_master_public_ip" {
#     value = google_compute_instance.tf_instance["jenkins-master"].network_interface[0].access_config[0].nat_ip
# }

# output "jenkins_master_private_ip" {
#     value = google_compute_instance.tf_instance["jenkins-master"].network_interface[0].network_ip
# }

# output "jenkins_slave_public_ip" {
#     value = google_compute_instance.tf_instance["jenkins-slave"].network_interface[0].access_config[0].nat_ip
# }

# output "jenkins_slave_private_ip" {
#     value = google_compute_instance.tf_instance["jenkins-slave"].network_interface[0].network_ip
# }

# output "ansible_controller_public_ip" {
#     value = google_compute_instance.tf_instance["ansible-controller"].network_interface[0].access_config[0].nat_ip
# }

# output "ansible_controller_private_ip" {
#     value = google_compute_instance.tf_instance["ansible-controller"].network_interface[0].network_ip
# }

output "ip_address" {
    value = {
        for instance in google_compute_instance.tf_instance:
        instance.name => {
            private_ip=instance.network_interface[0].network_ip
            public_ip=instance.network_interface[0].access_config[0].nat_ip
        }
    }
}