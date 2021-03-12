#!/bin/bash

read -p "Fullname: " FULLNAME
read -p "Email: " EMAIL

# passwordless sudo
echo "%adm ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/adm

# base packages
sudo apt update
sudo apt install --yes vim openssh-server software-properties-common apt-transport-https ca-certificates curl gnupg lsb-release git build-essential
echo -e ":syntax on\n:set softtabstop=2\n:set shiftwidth=2\n:set shiftround\n:set nojoinspaces\n:set noautoindent\n:set nu" > ~/.vimrc

# npm/node
curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install --yes nodejs
rm -f nodesource_setup.sh

# terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository --yes "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install --yes terraform
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt update && sudo apt install --yes ansible-base

# docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo adduser $USER docker
rm -f get-docker.sh

# docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# git config
git config --global user.name "$FULLNAME"
git config --global user.email "$EMAIL"

# user adjustments
rm -rf ~/Documents/ ~/Music/ ~/Pictures/ ~/Public/ ~/Templates/ ~/Videos/ &&\
mkdir ~/workspace

echo 'pref("browser.startup.homepage", "https://github.com/heiseacademy/cdlab-infra");' | sudo tee /etc/firefox/syspref.js
echo -e "user-db:user\nsystem-db:local" | sudo tee /etc/dconf/profile/user
sudo mkdir /etc/dconf/db/local.d/
echo -e "[org/gnome/shell]\nfavorite-apps = ['firefox.desktop', 'gnome-terminal.desktop', 'nautilus.desktop']" | sudo tee /etc/dconf/db/local.d/00-favorite-apps
sudo mkdir /etc/dconf/db/local.d/locks
echo -e "/org/gnome/shell/favorite-apps" | sudo tee /etc/dconf/db/local.db/locks/favorite-apps
sudo dconf update

# installed tools overview
echo -e "\n=============================================\n"
terraform -v
ansible --version
docker --version
docker-compose --version
npm -v

echo -e "\n=============================================\n= Bitte nun einmal ab- und wieder anmelden, =\n= um die Änderungen zu aktivieren!          = \n=============================================\n"
