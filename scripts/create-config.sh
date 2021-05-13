#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd )"
set -e

HA_CONFIG_FOLDER=~/.heiseacademy

SHOW_USAGE=0

CDLAB_BASE_DOMAIN=$1
DO_API_TOKEN=$2
CDLAB_PASSWORD_ADMIN=$3

if [ -z "$CDLAB_BASE_DOMAIN" ];then
  echo "ERROR: ARG1 empty!"
  SHOW_USAGE=1
fi
if [ -z "$DO_API_TOKEN" ];then
  echo "ERROR: ARG2 empty!"
  SHOW_USAGE=1
fi

if [ $SHOW_USAGE -eq 1 ];then
  echo "Usage: $0 \"<base DNS Domain>\" \"<DigitalOcean API Token>\" \"<Admin and User Password (OPTIONAL)>\""
  exit 1
fi

# ------------ Token check
echo "Checking DigitalOcean API Access with your token..."
DO_API_CHECK=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $DO_API_TOKEN" "https://api.digitalocean.com/v2/actions")
echo -n "DigitalOcean API response code: "
echo $DO_API_CHECK

if [ $DO_API_CHECK -ne 200 ];then
  echo "ERROR: DigitalOcean API Access failed! Please check your Token!"
  exit 1
fi

echo "OK."
# ------------- Already configured check
if [ -d "$HA_CONFIG_FOLDER" ];then
  echo "ERROR: Config Folder $HA_CONFIG_FOLDER already exists! Please remove manually if you like to change it."
  exit 1
fi

# ------------- Create config folder
[ -d "$HA_CONFIG_FOLDER" ] || mkdir $HA_CONFIG_FOLDER

# ------------- Save Username
if [ -z "$USER" ];then
  echo "ERROR: Environment Variable \$USER seems to be empty. Please set USER=<your prefered username> manually and start over again!"
  exit 1
fi
CDLAB_USERNAME_USER=$USER
echo -n $CDLAB_USERNAME_USER > $HA_CONFIG_FOLDER/CDLAB_USERNAME_USER

# ------------- Create/fetch & save some random passwords
if [ -z "$CDLAB_PASSWORD_ADMIN" ];then
  CDLAB_PASSWORD_ADMIN=$(curl -sS 'https://makemeapassword.ligos.net/api/v1/alphanumeric/plain?c=1&l=8' | tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~')
fi
CDLAB_PASSWORD_USER=$CDLAB_PASSWORD_ADMIN
CDLAB_PASSWORD_JENKINS=$CDLAB_PASSWORD_ADMIN
echo -n $CDLAB_PASSWORD_ADMIN > $HA_CONFIG_FOLDER/CDLAB_PASSWORD_ADMIN
echo -n $CDLAB_PASSWORD_USER > $HA_CONFIG_FOLDER/CDLAB_PASSWORD_USER
echo -n $CDLAB_PASSWORD_JENKINS > $HA_CONFIG_FOLDER/CDLAB_PASSWORD_JENKINS

# ------------- Create/fetch & save a personal gitlab api token
GITLAB_API_TOKEN=$(curl -sS 'https://makemeapassword.ligos.net/api/v1/alphanumeric/plain?c=1&l=32' | tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~')
echo -n $GITLAB_API_TOKEN > $HA_CONFIG_FOLDER/GITLAB_API_TOKEN

# ------------- Create/fetch & save an example app db password
TUTORIALS_API_POSTGRES_PASSWORD=$(curl -sS 'https://makemeapassword.ligos.net/api/v1/alphanumeric/plain?c=1&l=32' | tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~')
echo -n $TUTORIALS_API_POSTGRES_PASSWORD > $HA_CONFIG_FOLDER/TUTORIALS_API_POSTGRES_PASSWORD

# ------------- Save DigitalOcean API Token
echo -n $DO_API_TOKEN > $HA_CONFIG_FOLDER/DO_API_TOKEN

# ------------- Save CDLab Base Domnain
echo -n $CDLAB_BASE_DOMAIN > $HA_CONFIG_FOLDER/CDLAB_BASE_DOMAIN

# ------------- Create Provisioning & Serviceuser SSH Keypair
OLD_PWD=$(pwd)
cd $HA_CONFIG_FOLDER
ssh-keygen -t rsa -b 4096 -f id_rsa -N ''
ssh-keygen -t rsa -b 4096 -f id_rsa-serviceuser -N ''
ssh-keygen -t rsa -b 4096 -f id_rsa-jenkins -N ''
cd $OLD_PWD

# Install ssh config for CDLAB_BASE_DOMAIN Hosts
if [ ! -d ~/.ssh ];then
  mkdir ~/.ssh
  chown 700 ~/.ssh
fi

[ ! -f ~/.ssh/config ] && touch ~/.ssh/config || true
if grep $CDLAB_BASE_DOMAIN ~/.ssh/config;then
  echo "ssh config for CDLAB_BASE_DOMAIN already set!"
else
  cat >> ~/.ssh/config <<EOF
host *.${CDLAB_BASE_DOMAIN}
  user root
  IdentityFile ~/.heiseacademy/id_rsa
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF
fi

# Create welcome.html in User Home
sed -e "s;__BASE_DOMAIN__;$CDLAB_BASE_DOMAIN;g" $SCRIPT_DIR/welcome.html.tpl > ~/welcome.html

# ------------- Print Results
echo
echo "==========================="
echo "Attention:"
echo "Please copy this public ssh-key into your DigitalOcean account and name it \"heiseacademy\"!"
echo "DigitalOcean.com -> Account -> Settings -> Security -> SSH Keys"
echo
cat $HA_CONFIG_FOLDER/id_rsa.pub
echo
echo "Your Passwords for $CDLAB_USERNAME_USER/admin/root and some example users are:"
echo "Passwort for Jenkins/Gitlab User ${CDLAB_USERNAME_USER}: ${CDLAB_PASSWORD_USER}"
echo "Passwort for Jenkins User admin: $CDLAB_PASSWORD_ADMIN"
echo "Passwort for Gitlab User root:   $CDLAB_PASSWORD_ADMIN"
echo
echo "==========================="
