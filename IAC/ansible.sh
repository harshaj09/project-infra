#!/bin/sh
sudo apt update
sudo apt install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible -y
sudo apt install ansible -y