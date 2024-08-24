provider "google" {
    project = var.my_project
    region = var.region
    credentials = file("creds.json")
}