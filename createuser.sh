#!/bin/sh

username=$1
password=$2

sudo mkdir /home/$username

sudo useradd -d /home/$username -s /bin/bash -p $(openssl passwd -1 $password) $username

sudo groupadd docker
sudo usermod -aG docker $username

sudo chmod 777 /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo echo "AllowUsers ubuntu $username" >> /etc/ssh/sshd_config
sudo chmod 644 /etc/ssh/sshd_config
sudo systemctl restart ssh
