## Heise Academy
# Continuous Delivery Lab

Das CD Lab ist eine Instanz-basierte (Virtuelle Maschinen, Docker Container, Kubernetes) Continuous Delivery Experimentierumgebung die mit Hilfe der [IaC](https://en.wikipedia.org/wiki/Infrastructure_as_code) Tools
* terraform
* ansible
* docker-compose

auf der Cloudplatform [DigitalOcean](https://www.digitalocean.com/) deployed werden kann.
## Übersicht
In der Grundinstallation besteht das CD Lab aus zwei VMs:
* Gitlab
* Jenkins

Dazu kommen, je nach Zielsetzung, unterschiedliche "Deployment Environments" - ausgeführt als
* Dockerhosts (VMs mit docker/docker-compose Installation)
* Kubernetes Instanz (VM mit Single Node Kubernetes Instanz)

## Installation
Die Installation des CD Labs erfolgt in mehreren Schritten:

1) Reservierung einer eigenen (kostenlosen) Domain auf [freenom.com](http://www.freenom.com/en/index.html)
2) Erstellung der leeren Virtuellen Machinen als DigitalOcean Droplets mit [terraform](https://www.terraform.io/)
3) Provisionierung der VMs mit [Ansible](https://www.ansible.com/) und [docker-compose](https://docs.docker.com/compose/)

### Tools
Für das Setup Deines CD Labs benötigst Du die **Kommandozeilen Tools** [git](), [terraform](https://www.terraform.io/) und [Ansible](https://www.ansible.com/). Optional sind lokale Installationen von [docker](https://docs.docker.com) und [docker-compose](https://docs.docker.com/compose/).
Als Shell verwendest Du am besten eine [Bash](https://www.gnu.org/software/bash/).
#### bash
##### Windows
Auf Windows Systemen hat sich [Git for Windows](https://gitforwindows.org/) bewährt - eine Git Installation, die eine Bash gleich mit bringt. Eine gute Installationsanleitung findest Du hier: [https://www.atlassian.com/de/git/tutorials/git-bash](https://www.atlassian.com/de/git/tutorials/git-bash)
##### macOS, Linux
Die Code-Beispiele sollten in allen Standard-Shells (z-Shell, Dash, Bash) sowohl von macOS als auch allen gängigen Linuxen laufen. Wenn Du sicher gehen willst, nutze eine [bash](https://www.gnu.org/software/bash/) (Version >= 5.0).

macOS spezifische Anleitungen: [Installation bash 5](https://scriptingosx.com/2019/02/install-bash-5-on-macos/), [bash als default shell](https://www.howtogeek.com/444596/how-to-change-the-default-shell-to-bash-in-macos-catalina/)

#### git
Um die Code-Beispiele nachvollziehen zu können, benötigst Du eine [git](https://git-scm.com/) (Version >= 2.30) Kommandozeilen Installation ([Windows](https://gitforwindows.org), [macOS](https://www.atlassian.com/de/git/tutorials/install-git#mac-os-x)).

Bitte stelle sicher, dass die globalen git Konfigurationsparameter ```user.name``` und ```user.email``` gesetzt sind:

```bash
$ git config --list | grep user
user.name=Tim Tester
user.email=tim.tester@example.com
```

Falls nicht, kannst Du sie mit
```bash
git config --global user.name "<Vorname> <Nachname>"
git config --global user.email "<Email Adresse>"
```
setzen.

#### terraform
Die [terraform CLI](https://www.terraform.io) (Version >= 0.14.4) findest Du als Binärpaket für alle gängigen Plattformen hier:

[https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html)

Mit ```terraform version``` kannst Du die Installation testen: 
```bash
$ terraform version
Terraform v0.14.4
```

#### Ansible

Die Installtion von **Ansible** (Version >= 2.10.5) ist hier beschrieben:

[https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

Mit ```ansible --version``` kannst Du die Installation überprüfen:

```bash
$ ansible --version
ansible 2.10.5
  config file = ~/.ansible.cfg
  configured module search path = ['~/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = ~/.virtualenvs/cdlab-infra/lib/python3.8/site-packages/ansible
  executable location = ~/.virtualenvs/cdlab-infra/bin/ansible
  python version = 3.8.1 (default, Jan  8 2020, 16:24:34) [Clang 11.0.0 (clang-1100.0.33.16)]
```

---

Mein Vorgehen orientiert sich an diesem Tutorial aus dem Digital Ocean Community: [How To Install and Configure Ansible on Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-ansible-on-ubuntu-20-04) 

#### Jenkins
