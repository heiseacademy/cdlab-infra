## Heise Academy
# Continuous Delivery Lab

Das CD Lab ist eine Instanz-basierte (Virtuelle Maschinen, Docker Container, Kubernetes) Continuous Delivery Experimentierumgebung, die mit Hilfe der [IaC](https://en.wikipedia.org/wiki/Infrastructure_as_code) Tools
* terraform
* ansible
* docker-compose

auf der Cloudplattform [DigitalOcean](https://www.digitalocean.com/) deployed werden kann.

Im Folgenden ist lediglich das manuelle Aufsetzen der nötigen Tools erklärt. Wie du damit das CD Lab konkret erzeugst, erfährst du im Kurs!

WICHTIG: Bitte wende vorzugsweise das vollständig geskriptete Toolsetup auf einer frischen Ubuntu 20.04 VM (die musst du dir zuvor erstellen, wie im Kurs besprochen) an. Das Setupscript findest du im Unterordner "toolboxvm".

```bash
cd ./toolboxvm
bash install.sh
```

 Die Schritt-für-Schritt Beschreibung hier dient lediglich als Dokumentation.

Wenn die Tools installiert sind, erstelle bitte mit
```bash
bash scripts/create-config.sh "<dein individuelle basedomain>" "<dein digital oceal api key>"
```
eine individuelle .heiseacademy Config.

Jetzt sind alle Tools bereit und du kannst mit dem Bootstrappen und Provisionieren des eigentlichen CD Labs fortfahren!
### Manuelle Tool Installation
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

Alternativ zur ativen Installation von terraform kannst Du auch ein terraform Dockerimage nutzen: Im Verzeichnis terraform/ findest Du einen passenden docker-basierten terraform Wrapper:

```bash
$ cd terraform
$ terraform-w version
Terraform v0.14.7
```
#### Ansible

Die Installation von **Ansible** (Version >= 2.10.4, < 3.0.0) ist hier beschrieben:

[https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

Da die Installation unter Windows 10 relativ aufwändig ist, liegen im Unterverzeichnis ansible zwei docker-basierte Ansible Wrapper bereit:

```bash
$ cd ansible
$ ./ansible-w --version
ansible 2.10.4
  config file = /ansible/ansible.cfg
  [...]

$ ./ansible-playbook-w --version
ansible-playbook 2.10.4
  config file = /ansible/ansible.cfg
  [...]
```
