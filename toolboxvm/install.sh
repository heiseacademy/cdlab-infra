#!/usr/bin/env bash
set -e

TB_VERSION="2.1.0"
TB_TESTED_AT="2022-07-10T18:01:00CET"

TERRAFORM_VERSION="0.15.5"

ANSIBLE_VERSION="2.12.7-1ppa~focal"
ANSIBLE_GALAXY_ANSIBLE_POSIX_VERSION="1.3.0"
ANSIBLE_GALAXY_COMMUNITY_DOCKER_VERSION="2.0.0"
ANSIBLE_GALAXY_COMMUNITY_GENERAL_VERSION="4.0.1"
MITOGEN_VERSION="c1e72b82258752d4a3155e88806c2e1235805eff"

DOCKER_CE_VERSION="5:20.10.10~3-0~ubuntu-focal"
DOCKER_CE_CLI_VERSION="5:20.10.10~3-0~ubuntu-focal"
CONTAINERD_VERSION="1.4.11-1"
DOCKER_COMPOSE_VERSION="1.28.5"

VSCODE_VERSION="1.62.1-1636111026"

NODEJS_VERSION="14.x" # 14.x is correct, see https://deb.nodesource.com/

function do_install() {
  # passwordless sudo
  echo "Setting up passwordless sudo..."
  echo "%adm ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/adm
  echo "------------------------------------"
  
  # update system
  echo "Updating Ubuntu..."
  echo "Switching to german ubuntu mirror..."
  sudo sed -i -e 's;//us.ar;//de.ar;g' /etc/apt/sources.list
  echo "Updating package sources..."
  sudo apt update
  echo "Upgrading packages (will take up to 10 minutes)..."
  sudo apt upgrade --yes
  echo "Removing obsolete packages..."
  sudo apt autoremove --yes
  echo "------------------------------------"
  
  # base packages
  echo "Installing some base packages (will take up to 2 minutes)..."
  sudo apt install --yes snapd vim jq dnsutils net-tools openssh-server \
                        software-properties-common apt-transport-https \
                        ca-certificates curl gnupg lsb-release git \
                        build-essential
  echo -e ":syntax on\n:set softtabstop=2\n:set shiftwidth=2\n:set shiftround\n:set nojoinspaces\n:set noautoindent\n:set nu" > ~/.vimrc
  echo "------------------------------------"
  
  # npm/node
  echo "Installing nodejs ($NODEJS_VERSION)..."
  curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION} -o nodesource_setup.sh
  sudo bash nodesource_setup.sh
  sudo apt install --yes nodejs
  rm -f nodesource_setup.sh
  sudo apt-mark hold nodejs
  echo "------------------------------------"
  
  # terraform
  echo "Installing terraform ($TERRAFORM_VERSION)..."
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository --yes "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt-get update && sudo apt-get install --yes terraform=${TERRAFORM_VERSION}
  sudo apt-mark hold terraform
  echo "------------------------------------"
  
  # ansible
  echo "Installing ansible ($ANSIBLE_VERSION)..."
  sudo apt-add-repository --yes --update ppa:ansible/ansible
  sudo apt update && sudo apt install --yes ansible-core=${ANSIBLE_VERSION}
  sudo apt-mark hold ansible-core
  echo "Installing some ansible modules via ansible-galaxy..."
  ansible-galaxy collection install ansible.posix:${ANSIBLE_GALAXY_ANSIBLE_POSIX_VERSION}
  ansible-galaxy collection install community.general:${ANSIBLE_GALAXY_COMMUNITY_GENERAL_VERSION}
  ansible-galaxy collection install community.docker:${ANSIBLE_GALAXY_COMMUNITY_DOCKER_VERSION}
  echo "------------------------------------"
  
  # python pip
  echo "Installing python pip..."
  sudo apt install --yes python3-pip
  echo "------------------------------------"
  
  # Postman
  echo "Installing postman..."
  sudo snap install postman
  echo "------------------------------------"
  
  # docker
  sudo apt-get install --yes ca-certificates curl gnupg lsb-release
  if [ -f /usr/share/keyrings/docker-archive-keyring.gpg ];then
    echo "docker-archive-keyring.gpg already exists."
  else
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  fi
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install --yes docker-ce=${DOCKER_CE_VERSION} docker-ce-cli=${DOCKER_CE_CLI_VERSION} containerd.io=${CONTAINERD_VERSION}
  sudo apt-mark hold docker-ce docker-ce-cli containerd.io
  sudo adduser $USER docker
  echo "------------------------------------"
  
  # docker-compose
  echo "Installinfg docker-compose..."
  sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  echo "------------------------------------"
  
  # git config
  echo "Setting up git for user $USER..."
  git config --global user.name "$USER"
  git config --global user.email "$USER@example.com"
  git config --global advice.detachedHead false
  echo "------------------------------------"
  
  # user adjustments / sidebar 
  rm -rf ~/Documents/ ~/Music/ ~/Pictures/ ~/Public/ ~/Templates/ ~/Videos/
  [ ! -d ~/workspace ] && mkdir ~/workspace || true

  echo "Setting up browser..."
  echo 'pref("browser.startup.homepage", "file://home/$USER/welcome.html");' | sudo tee /etc/firefox/syspref.js
  echo -e "user-db:user\nsystem-db:local" | sudo tee /etc/dconf/profile/user
  [ ! -d /etc/dconf/db/local.d/ ] && sudo mkdir /etc/dconf/db/local.d/ || true
  echo -e "[org/gnome/shell]\nfavorite-apps = ['code.desktop', 'gnome-terminal.desktop', 'firefox.desktop', 'postman_postman.desktop', 'nautilus.desktop']" | sudo tee /etc/dconf/db/local.d/00-favorite-apps
  [ ! -d /etc/dconf/db/local.d/locks ] && sudo mkdir /etc/dconf/db/local.d/locks || true
  echo -e "/org/gnome/shell/favorite-apps" | sudo tee /etc/dconf/db/local.d/locks/favorite-apps
  sudo dconf update
  echo "------------------------------------"

  # vscode
  echo "Installing Visual Studio Code..."
  if [ -f /etc/apt/trusted.gpg.d/packages.microsoft.gpg ];then
    echo "packages.microsoft.gpg already exists."
  else
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
  fi
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  sudo apt update
  sudo apt install code=${VSCODE_VERSION}
  code --install-extension pkief.material-icon-theme
  code --install-extension ms-azuretools.vscode-docker
  code --install-extension hashicorp.terraform
  code --install-extension ms-python.python
  sudo apt-mark hold code
  echo "------------------------------------"

  # clone course specific repos
  echo "Cloning cource specific repos..."
  if [ ! -d ~/workspace/cdlab-infra ];then
    pushd ~/workspace
    git clone https://github.com/heiseacademy/cdlab-infra.git
    cd cdlab-infra/ansible/plugins
    git clone https://github.com/mitogen-hq/mitogen.git
    cd mitogen
    git checkout ${MITOGEN_VERSION}
    popd
  fi
  echo "------------------------------------"
  
  echo "Adjusting some presets..."
  # Set nano as standard cmd line editor
  if ! grep 'EDITOR=' ~/.bashrc;then
    echo 'export EDITOR=nano' >> ~/.bashrc
  fi
  
  # Add cdlab-infra/scripts to PATH
  if ! grep 'cdlab-infra/scripts' ~/.bashrc;then
    echo 'export PATH=$PATH:~/workspace/cdlab-infra/scripts' >> ~/.bashrc
  fi
  
  # set hostname alias for db
  if ! grep 'localhost db' /etc/hosts;then
    sudo sed -i 's/localhost$/localhost db/g' /etc/hosts
  fi
  echo "------------------------------------"

  # installed tools overview
  echo "Installation & setup finished successfully!"
  echo $TOOLBOXVM_VERSION > ~/.toolboxvm_version

  echo "===================================================="
  echo "= Rebooting in 15s to activate changes...          ="
  echo "===================================================="

  sleep 15

  sudo shutdown --reboot now
}

do_install
