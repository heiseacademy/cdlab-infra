#!/usr/bin/env bash

HA_CONFIG_FOLDER=~/.heiseacademy

CDLAB_BASE_DOMAIN=$(<$HA_CONFIG_FOLDER/CDLAB_BASE_DOMAIN)
CDLAB_PASSWORD_ADMIN=$(<$HA_CONFIG_FOLDER/CDLAB_PASSWORD_ADMIN)
CDLAB_USERNAME_USER=$(<$HA_CONFIG_FOLDER/CDLAB_USERNAME_USER)
CDLAB_PASSWORD_USER=$(<$HA_CONFIG_FOLDER/CDLAB_PASSWORD_USER)
CDLAB_PASSWORD_JENKINS=$(<$HA_CONFIG_FOLDER/CDLAB_PASSWORD_JENKINS)
DO_API_TOKEN=$(<$HA_CONFIG_FOLDER/DO_API_TOKEN)
GITLAB_API_TOKEN=$(<$HA_CONFIG_FOLDER/GITLAB_API_TOKEN)
TUTORIALS_API_POSTGRES_PASSWORD=$(<$HA_CONFIG_FOLDER/TUTORIALS_API_POSTGRES_PASSWORD)

echo "==========================="
echo "Base Domain: $CDLAB_BASE_DOMAIN"
echo
echo "Jenkins URL:         https://jenkins.$CDLAB_BASE_DOMAIN/"
echo "Gitlab URL:          https://gitlab.$CDLAB_BASE_DOMAIN/"
echo "Docker Registry API: https://registry.$CDLAB_BASE_DOMAIN/v2/"
echo
echo "Passwort for Jenkins & Gitlab User ${CDLAB_USERNAME_USER}: ${CDLAB_PASSWORD_USER}"
echo "Passwort for Gitlab User jenkins: ${CDLAB_PASSWORD_JENKINS}"
echo 
echo "Passwort for Jenkins User admin: $CDLAB_PASSWORD_ADMIN"
echo "Passwort for Gitlab User root:   $CDLAB_PASSWORD_ADMIN"
echo
#echo "DigitalOcean API Token: $DO_API_TOKEN"
echo "Gitlab API Token: $GITLAB_API_TOKEN"
echo
echo "Tutorials API Postgres Password: $TUTORIALS_API_POSTGRES_PASSWORD"
echo "==========================="
