#!/bin/bash
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
  echo "Usage: $0 \"<base DNS Domain>\" \"<DigitalOcean API Token>\""
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
  #exit 1
fi

# ------------- Create config folder
[ -d "$HA_CONFIG_FOLDER" ] || mkdir $HA_CONFIG_FOLDER

# ------------- Fetch & save some random passwords
if [ -z "$CDLAB_PASSWORD_ADMIN" ];then
  CDLAB_PASSWORD_ADMIN=$(curl -sS 'https://makemeapassword.ligos.net/api/v1/alphanumeric/plain?c=1&l=8')
fi

echo $CDLAB_PASSWORD_ADMIN > $HA_CONFIG_FOLDER/CDLAB_PASSWORD_ADMIN
CDLAB_PASSWORD_LARA=$(curl -sS 'https://makemeapassword.ligos.net/api/v1/alphanumeric/plain?c=1&l=8')

echo $CDLAB_PASSWORD_LARA > $HA_CONFIG_FOLDER/CDLAB_PASSWORD_LARA
CDLAB_PASSWORD_TIM=$(curl -sS 'https://makemeapassword.ligos.net/api/v1/alphanumeric/plain?c=1&l=8')
echo $CDLAB_PASSWORD_TIM > $HA_CONFIG_FOLDER/CDLAB_PASSWORD_TIM

# ------------- Save DigitalOcean API Token
echo $DO_API_TOKEN > $HA_CONFIG_FOLDER/DO_API_TOKEN

# ------------- Save CDLab Base Domnain
echo $CDLAB_BASE_DOMAIN > $HA_CONFIG_FOLDER/CDLAB_BASE_DOMAIN

# ------------- Create Provisioning & Serviceuser SSH Keypair
OLD_PWD=$(pwd)
cd $HA_CONFIG_FOLDER
ssh-keygen -t rsa -b 4096 -f id_rsa -N ''
ssh-keygen -t rsa -b 4096 -f id_rsa-serviceuser -N ''
cd $OLD_PWD

# ------------- Print Results
echo
echo "==========================="
echo "Attention:"
echo "Please copy this public ssh-key into your DigitalOcean account and name it \"heiseacademy\"!"
echo "DigitalOcean.com -> Account -> Settings -> Security -> SSH Keys"
echo
cat $HA_CONFIG_FOLDER/id_rsa.pub
echo
echo "Your Passwords for admin/root and some example users are:"
echo "Passwort for Jenkins User admin: $CDLAB_PASSWORD_ADMIN"
echo "Passwort for Gitlab User root:   $CDLAB_PASSWORD_ADMIN"
echo "Password for Jenkins & Gitlab User lara: $CDLAB_PASSWORD_LARA"
echo "Password for Jenkins & Gitlab User tim:  $CDLAB_PASSWORD_TIM"
echo
echo "==========================="
