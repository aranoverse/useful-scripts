#!/bin/bash

sudo yum install -y docker

sudo systemctl start docker

sudo systemctl enable docker

# avoid sudo auth
sudo usermod -aG docker $USER
sudo gpasswd -a $USER docker

# reload user group
newgrp docker

docker --version

sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker-compose --version
