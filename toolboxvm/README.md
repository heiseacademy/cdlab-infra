## Heise Academy
# CDLab ToolboxVM
## tl;dr
```bash
wget -q -O - https://raw.githubusercontent.com/heiseacademy/cdlab-infra/main/toolboxvm/install.sh | bash
```
# Grundinstallation
## Passwordless sudo
```bash
echo "%adm ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/adm
```
## Basis Setup
```bash
sudo apt update
sudo apt install --yes vim openssh-server software-properties-common apt-transport-https ca-certificates curl gnupg lsb-release git build-essential

cat > ~/.vimrc <<EOF
:syntax on
:set softtabstop=2
:set shiftwidth=2
:set shiftround
:set nojoinspaces
:set noautoindent
:set nu
EOF

rm -rf Documents/ Music/ Pictures/ Public/ Templates/ Videos/
mkdir workspace
mkdir .setup
```
# Tool Installation 

## git
```bash
git config --global user.name "<Your-Full-Name>"
git config --global user.email "<your-email-address>"
```
## npm
```bash
curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install --yes nodejs
rm -f nodesource_setup.sh
node -v
```
## terraform
```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository --yes "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install --yes terraform
terraform -version
```
## ansible
```bash
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt update && sudo apt install --yes ansible-base
ansible --version
```
## docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo adduser $USER docker
rm -f get-docker.sh
```
## docker-compose
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## vscode
```bash
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install code
```
# CDLab spezifische Tools und Konfiguration
## Git Repo cdlab-infra
```bash
pushd ~ # cd ~ plus remember actual dir
[ -d Workspace ] || mkdir workspace
cd Workspace
git clone https://github.com/heiseacademy/cdlab-infra.git
popd # return to former actual dir
```
## .heise-academy Konfigurationsverzeichnis
Das .heise-academy Konfigurationsverzeichnis lässt sich am einfachsten per Skript erzeugen.

Voraussetzungen:
* ein DigitalOcean API Token
* eine eigene CDLab DNS Domain 

Hier findest du eine Anleitung, wie du dir mit wenigen Klicks ein Digital Ocean Api Token sowie eine eigene, kostenlose DNS Domain einrichten kannst: https://github.com/heiseacademy/cdlab-infra/blob/main/README.md

```bash
pushd ~/workspace/cdlab-infra
bash ./scripts/create-config.sh
```