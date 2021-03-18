#!/bin/bash
set -e

function do_install() {
  # passwordless sudo
  echo "%adm ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/adm

  # base packages
  sudo apt update
  sudo apt upgrade --yes
  sudo apt autoremove --yes
  sudo apt install --yes vim jq openssh-server software-properties-common apt-transport-https ca-certificates curl gnupg lsb-release git build-essential
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

  # ansible
  sudo apt-add-repository --yes --update ppa:ansible/ansible
  sudo apt update && sudo apt install --yes ansible-base
  ansible-galaxy collection install community.general
  ansible-galaxy collection install community.docker

  # python pip
  sudo apt install --yes python3-pip

  # docker
  if which docker;then
    echo "docker already installed"
  else
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo adduser $USER docker
    rm -f get-docker.sh
  fi

  # docker-compose
  sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

  # git config
  git config --global user.name "$USER"
  git config --global user.email "$USER@example.com"

  # user adjustments / sidebar 
  rm -rf ~/Documents/ ~/Music/ ~/Pictures/ ~/Public/ ~/Templates/ ~/Videos/
  [ ! -d ~/workspace ] && mkdir ~/workspace || true

  echo 'pref("browser.startup.homepage", "https://github.com/heiseacademy/cdlab-infra");' | sudo tee /etc/firefox/syspref.js
  echo -e "user-db:user\nsystem-db:local" | sudo tee /etc/dconf/profile/user
  [ ! -d /etc/dconf/db/local.d/ ] && sudo mkdir /etc/dconf/db/local.d/ || true
  echo -e "[org/gnome/shell]\nfavorite-apps = ['code.desktop', 'gnome-terminal.desktop', 'firefox.desktop', 'nautilus.desktop']" | sudo tee /etc/dconf/db/local.d/00-favorite-apps
  [ ! -d /etc/dconf/db/local.d/locks ] && sudo mkdir /etc/dconf/db/local.d/locks || true
  echo -e "/org/gnome/shell/favorite-apps" | sudo tee /etc/dconf/db/local.d/locks/favorite-apps
  sudo dconf update

  # vscode
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  sudo apt update
  sudo apt install code
  code --install-extension pkief.material-icon-theme
  code --install-extension ms-azuretools.vscode-docker
  code --install-extension hashicorp.terraform
  code --install-extension ms-python.python

  # clone course specific repos
  if [ ! -d ~/workspace/cdlab-infra ];then
    pushd ~/workspace
    git clone https://github.com/heiseacademy/cdlab-infra.git
    popd
  fi

  # installed tools overview
  terraform -v
  ansible --version
  docker --version
  docker-compose --version
  npm -v
  node --version

  echo "===================================================="
  echo "= Reboot, um die Änderungen zu aktivieren in 5s... ="
  echo "===================================================="

  sleep 5

  sudo shutdown --reboot now
}

do_install
