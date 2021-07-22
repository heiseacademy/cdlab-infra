## Heise Academy
# Continuous Delivery Lab

Das CD Lab ist eine Instanz-basierte (Virtuelle Maschinen, Docker Container, Kubernetes) Continuous Delivery Experimentierumgebung, die mit Hilfe der [IaC](https://en.wikipedia.org/wiki/Infrastructure_as_code) Tools

* terraform
* ansible
* docker-compose

auf der Cloudplattform [DigitalOcean](https://www.digitalocean.com/) deployed werden kann.

Um möglichst keine Probleme mit Betriebssystem- oder Toolversionsbedingten Inkompatibilitäten zu haben, lege ich dir ans Herz, eine frische Ubuntu 20.04 LTS Linux VM als ToolboxVM aufzusetzen (wie im Kurs beschrieben).

Auf diese ToolboxVM kannst du dann geskriptet und in einem Rutsch die oben genannten Tools wie folgt installieren:

Melde dich mit einem normalen Benutzeraccount an deiner Ubuntu 20.04 ToolboxVM an, öffne ein Terminal und führe bitte diesen Befehl aus:

```bash
wget -q -O - https://raw.githubusercontent.com/heiseacademy/cdlab-infra/main/toolboxvm/install.sh | bash
```

Nachdem die Tools installiert sind, benötigst du jetzt noch eine individuelle Konfiguration im Verzeichnis `~/.heiseacademy` aus der sich dann Terraform und Ansible beim Bootstrappen/Provisionieren der VMs bedienen können.

Dieses Konfigurationsverzeichnis erstellst du bitte mit dem Skript `~/workspace/cdlab-infra/scripts/create-config.sh` wie folgt:

```bash
bash ~/workspace/cdlab-infra/scripts/create-config.sh "<deine individuelle Basedomain>" "<dein DigitalOcean Api Key>"
```

Jetzt sind alle Tools bereit und du hast eine individuelle `~/.heiseacademy` Konfiguration in deinem Homeverzeichnis. Nun kannst du mit dem Bootstrappen und Provisionieren des eigentlichen CD Labs fortfahren!

Eine Schritt-für-Schritt Dokumentation des Tool Setups findest du zusätzlich [hier](https://github.com/heiseacademy/cdlab-infra/tree/main/toolboxvm).
