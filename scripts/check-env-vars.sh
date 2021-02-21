#!/bin/bash

echo -n "Checking mandatory Environment Variables for provisioning process... "

OVERALL_EXIT_CODE=0
VARS_TO_TEST="CDLAB_BASE_DOMAIN CDLAB_PASSWORD_ADMIN CDLAB_PASSWORD_TIM CDLAB_PASSWORD_LARA CDLAB_SSHKEY_PUB_SERVICEUSER CDLAB_SSHKEY_PRIV_SERVICEUSER DO_API_TOKEN GIT_SSH_COMMAND TF_VAR_do_api_token TF_VAR_do_ssh_key TF_VAR_cdlab_base_domain ANSIBLE_SSH_ARGS"

for TEST_VAR in $VARS_TO_TEST;do
  if [ -z "${!TEST_VAR}" ];then
    echo
    echo "$TEST_VAR must not be empty!"
    OVERALL_EXIT_CODE=1
  fi
done

if [ $OVERALL_EXIT_CODE -eq 0 ];then
  echo "OK - go ahead!"
else
  echo "NOT OK - Some mandatory Environment Variables were empty! Please see .env and/or README.md for help."
  exit $OVERALL_EXIT_CODE
fi
exit $OVERALL_EXIT_CODE
