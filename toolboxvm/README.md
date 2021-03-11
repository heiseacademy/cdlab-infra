## Heise Academy
# CDLab ToolboxVM
# Grundinstallation
## Cleanup
```bash
rm -rf Documents/ Music/ Pictures/ Public/ Templates/ Videos/
mkdir Workspace
```
## Passwordless sudo
```bash
echo "%adm ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/adm
```
# Tool Installation 
## Basis Pakete
```bash
sudo apt update
sudo apt install openssh-server software-properties-common apt-transport-https ca-certificates curl gnupg lsb-release git
```
## terraform
```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
terraform -version
```
## ansible
```bash
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt update
sudo apt install ansible
ansible --version
```
## docker
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
sudo apt-add-repository "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
sudo adduser $USER docker
sudo docker run hello-world
```
## git
# CDLab spezifische Tools und Konfirguration
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