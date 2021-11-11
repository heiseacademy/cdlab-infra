#!/usr/bin/env bash
set -e

TB_VERSION="2.0.0"
TB_LOG="~/.toolboxvm_setup_log"

TERRAFORM_VERSION="0.15.5"
ANSIBLE_VERSION="2.11.6-1ppa~focal"
DOCKER_CE_VERSION="5:20.10.10~3-0~ubuntu-focal"
DOCKER_CE_CLI_VERSION="5:20.10.10~3-0~ubuntu-focal"
CONTAINERD_VERSION="1.4.11-1"
DOCKER_COMPOSE_VERSION="1.28.5"

NODEJS_VERSION="14.x" # 14.x is correct, see https://deb.nodesource.com/

function do_install() {
  # passwordless sudo
  echo "Setting up passwordless sudo..."
  echo "%adm ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/adm

  # update system
  echo "Updating Ubuntu..."
  sudo apt update > $TB_LOG
  sudo apt upgrade --yes >> $TB_LOG
  sudo apt autoremove --yes >> $TB_LOG
  
  # base packages
  echo "Installing some base packages..."
  sudo apt install --yes snapd vim jq dnsutils net-tools openssh-server \
                        software-properties-common apt-transport-https \
                        ca-certificates curl gnupg lsb-release git \
                        build-essential >> $TB_LOG
  echo -e ":syntax on\n:set softtabstop=2\n:set shiftwidth=2\n:set shiftround\n:set nojoinspaces\n:set noautoindent\n:set nu" > ~/.vimrc

  # npm/node
  echo "Installing nodejs ($NODEJS_VERSION)..."
  curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION} -o nodesource_setup.sh
  sudo bash nodesource_setup.sh >> $TB_LOG
  sudo apt install --yes nodejs >> $TB_LOG
  rm -f nodesource_setup.sh

  # terraform
  echo "Installing terraform ($TERRAFORM_VERSION)..."
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository --yes "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt-get update && sudo apt-get install --yes terraform=${TERRAFORM_VERSION} >> $TB_LOG
  sudo apt-mark hold terraform >> $TB_LOG
  
  # ansible
  echo "Installing ansible ($ANSIBLE_VERSION)..."
  sudo apt-add-repository --yes --update ppa:ansible/ansible
  sudo apt update && sudo apt install --yes ansible-core=${ANSIBLE_VERSION} >> $TB_LOG
  sudo apt-mark hold ansible-core >> $TB_LOG
  echo "Installing some ansible modules via ansible-galaxy..."
  ansible-galaxy collection install ansible.posix >> $TB_LOG
  ansible-galaxy collection install community.general >> $TB_LOG
  ansible-galaxy collection install community.docker >> $TB_LOG

  # python pip
  sudo apt install --yes python3-pip
  
  # Postman
  sudo snap install postman

  # docker
  if which docker;then
    echo "docker already installed"
  else
    sudo apt-get install --yes a-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce=${DOCKER_CE_VERSION} docker-ce-cli=${DOCKER_CE_CLI_VERSION} containerd.io=${CONTAINERD_VERSION}
    sudo apt-mark hold docker-ce docker-ce-cli containerd.io
  sudo adduser $USER docker
  fi

  # docker-compose
  sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

  # git config
  git config --global user.name "$USER"
  git config --global user.email "$USER@example.com"

  # user adjustments / sidebar 
  rm -rf ~/Documents/ ~/Music/ ~/Pictures/ ~/Public/ ~/Templates/ ~/Videos/
  [ ! -d ~/workspace ] && mkdir ~/workspace || true

  echo 'pref("browser.startup.homepage", "file://home/$USER/welcome.html");' | sudo tee /etc/firefox/syspref.js
  echo -e "user-db:user\nsystem-db:local" | sudo tee /etc/dconf/profile/user
  [ ! -d /etc/dconf/db/local.d/ ] && sudo mkdir /etc/dconf/db/local.d/ || true
  echo -e "[org/gnome/shell]\nfavorite-apps = ['code.desktop', 'gnome-terminal.desktop', 'firefox.desktop', 'postman_postman.desktop', 'nautilus.desktop']" | sudo tee /etc/dconf/db/local.d/00-favorite-apps
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
  
  # Set nano as standard cmd line editor
  if ! grep 'EDITOR=' ~/.bashrc;then
    echo 'export EDITOR=nano' >> ~/.bashrc
  fi
  
  # Add cdlab-infra/scripts to PATH
  if ! grep 'cdlab-infra/scripts' ~/.bashrc;then
    echo 'export PATH=$PATH:cdlab-infra/scripts' >> ~/.bashrc
  fi
  
  # set hostname alias for db
  if ! grep 'localhost db' /etc/hosts;then
    sudo sed -i 's/localhost$/localhost db/g' /etc/hosts
  fi

  # installed tools overview
  terraform -v
  ansible --version
  docker --version
  docker-compose --version
  npm -v
  node --version

  echo $TOOLBOXVM_VERSION > ~/.toolboxvm_version

  echo "===================================================="
  echo "= Reboot, um die Änderungen zu aktivieren in 5s... ="
  echo "===================================================="

  sleep 5

  sudo shutdown --reboot now
}

do_install
