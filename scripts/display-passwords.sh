#!/usr/bin/env bash
PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd )"

HA_CONFIG_FOLDER=~/.heiseacademy

CDLAB_BASE_DOMAIN=$(<$HA_CONFIG_FOLDER/CDLAB_BASE_DOMAIN)
CDLAB_PASSWORD_ADMIN=$(<$HA_CONFIG_FOLDER/CDLAB_PASSWORD_ADMIN)
CDLAB_PASSWORD_LARA=$(<$HA_CONFIG_FOLDER/CDLAB_PASSWORD_LARA)
CDLAB_PASSWORD_TIM=$(<$HA_CONFIG_FOLDER/CDLAB_PASSWORD_TIM)
DO_API_TOKEN=$(<$HA_CONFIG_FOLDER/DO_API_TOKEN)

echo "==========================="
echo "Base Domain: $CDLAB_BASE_DOMAIN"
echo
echo "Jenkins URL:         https://jenkins.$CDLAB_BASE_DOMAIN/"
echo "Gitlab URL:          https://gitlab.$CDLAB_BASE_DOMAIN/"
echo "Docker Registry API: https://registry.$CDLAB_BASE_DOMAIN/v2/"
echo
echo "Passwort for Jenkins User admin: $CDLAB_PASSWORD_ADMIN"
echo "Passwort for Gitlab User root:   $CDLAB_PASSWORD_ADMIN"
echo "Password for Jenkins & Gitlab User lara: $CDLAB_PASSWORD_LARA"
echo "Password for Jenkins & Gitlab User tim:  $CDLAB_PASSWORD_TIM"
echo
echo "DigitalOcean API Token: $DO_API_TOKEN"
echo "==========================="
