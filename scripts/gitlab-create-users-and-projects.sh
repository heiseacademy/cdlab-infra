#!/usr/bin/env bash
set -e

HA_CONFIG_FOLDER=~/.heiseacademy
EXAMPLE_PROJECTS="Tutorials App,tutorials,tutorials-api,tutorials-api,https://git.pingworks.net/trainings/cdlab/tutorials-api.git"
EXAMPLE_PROJECTS="$EXAMPLE_PROJECTS;Tutorials App,tutorials,tutorials-ui,tutorials-ui,https://git.pingworks.net/trainings/cdlab/tutorials-ui.git"
EXAMPLE_PROJECTS="$EXAMPLE_PROJECTS;Tutorials App,tutorials,tutorials-envs,tutorials-envs,https://git.pingworks.net/trainings/cdlab/tutorials-envs.git"
EXAMPLE_PROJECTS="$EXAMPLE_PROJECTS;CDLab,cdlab,cdlab-infra,cdlab-infra,https://git.pingworks.net/trainings/cdlab/cdlab-infra.git"

if [ ! -d "$HA_CONFIG_FOLDER" ];then
  echo "ERROR: Config Folder $HA_CONFIG_FOLDER does not exist! Please run create-config.sh first!"
  exit 1
fi

GIT_SSH_COMMAND="ssh -i ~/.heiseacademy/id_rsa -F /dev/null"
GITLAB_API_TOKEN="$(< ~/.heiseacademy/GITLAB_API_TOKEN)"

CDLAB_BASE_DOMAIN="$(< ~/.heiseacademy/CDLAB_BASE_DOMAIN)"
CDLAB_PASSWORD_ADMIN="$(< ~/.heiseacademy/CDLAB_PASSWORD_ADMIN)"
CDLAB_USERNAME_USER="$(< ~/.heiseacademy/CDLAB_USERNAME_USER)"
CDLAB_PASSWORD_USER="$(< ~/.heiseacademy/CDLAB_PASSWORD_USER)"
CDLAB_PASSWORD_JENKINS="$(< ~/.heiseacademy/CDLAB_PASSWORD_JENKINS)"
CDLAB_SSHKEYPUB_USER="$(< ~/.heiseacademy/id_rsa.pub)"

CDLAB_SSHKEYPUB_JENKINS="$(< ~/.heiseacademy/id_rsa-jenkins.pub)"

GITLAB_HOST="gitlab.$(< ~/.heiseacademy/CDLAB_BASE_DOMAIN)"
GITLAB_API_URL="https://$GITLAB_HOST/api/v4"

# ------------ Setting up Gitlab User $CDLAB_USERNAME_USER

GITLAB_USER_ID=$(curl -sS -H "PRIVATE-TOKEN: $GITLAB_API_TOKEN" "$GITLAB_API_URL/users" | jq "map(select(.username == \"$CDLAB_USERNAME_USER\")) | .[0].id")
if [ "$GITLAB_USER_ID" = "null" ];then
  echo "Creating Gitlab user $CDLAB_USERNAME_USER..."
  GITLAB_USER_ID=$(curl -sS -X POST \
    -H "PRIVATE-TOKEN: $GITLAB_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$CDLAB_USERNAME_USER\", \"username\": \"$CDLAB_USERNAME_USER\", \"email\": \"$CDLAB_USERNAME_USER@example.com\", \"password\": \"$CDLAB_PASSWORD_USER\", \"can_create_group\": \"true\", \"skip_confirmation\": \"true\"}" \
    "$GITLAB_API_URL/users" | jq .id)

  echo "Gitlab user $CDLAB_USERNAME_USER created (id: $GITLAB_USER_ID)."

  echo "Setting ssh-Key for user $CDLAB_USERNAME_USER..."
    curl -sS -X POST \
    -H "PRIVATE-TOKEN: $GITLAB_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"title\": \"heiseacademy-${CDLAB_USERNAME_USER}-ssh-key\", \"key\": \"$CDLAB_SSHKEYPUB_USER\"}" \
    "$GITLAB_API_URL/users/$GITLAB_USER_ID/keys" | jq .id
else
  echo "Gitlab user $CDLAB_USERNAME_USER already exists (id: $GITLAB_USER_ID)!"
fi

# ------------ Setting up Gitlab User jenkins
GITLAB_JENKINS_USER_ID=$(curl -sS -H "PRIVATE-TOKEN: $GITLAB_API_TOKEN" "$GITLAB_API_URL/users" | jq "map(select(.username == \"jenkins\")) | .[0].id")
if [ "$GITLAB_JENKINS_USER_ID" = "null" ];then
  echo "Creating Gitlab user jenkins..."
  GITLAB_JENKINS_USER_ID=$(curl -sS -X POST \
    -H "PRIVATE-TOKEN: $GITLAB_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"jenkins\", \"username\": \"jenkins\", \"email\": \"jenkins@example.com\", \"password\": \"$CDLAB_PASSWORD_JENKINS\", \"can_create_group\": \"true\", \"skip_confirmation\": \"true\"}" \
    "$GITLAB_API_URL/users" | jq .id)

  echo "Gitlab user jenkins created (id: $GITLAB_JENKINS_USER_ID)."

  echo "Setting ssh-Key for user jenkins..."
  curl -sS -X POST \
    -H "PRIVATE-TOKEN: $GITLAB_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"title\": \"heiseacademy-jenkins-ssh-key\", \"key\": \"$CDLAB_SSHKEYPUB_JENKINS\"}" \
    "$GITLAB_API_URL/users/$GITLAB_JENKINS_USER_ID/keys" | jq .id
else
  echo "Gitlab user jenkins already exists (id: $GITLAB_JENKINS_USER_ID)!"
fi

# ------------ Setting up Gitlab Example Projects
IFS=';'
for P in $EXAMPLE_PROJECTS;do
  GITLAB_GROUP_FULLNAME=$(echo $P | awk -F',' '{print $1;}')
  GITLAB_GROUP=$(echo $P | awk -F',' '{print $2;}')
  GITLAB_PROJECT_FULLNAME=$(echo $P | awk -F',' '{print $3;}')
  GITLAB_PROJECT=$(echo $P | awk -F',' '{print $4;}')
  SOURCE_GIT_URL=$(echo $P | awk -F',' '{print $5;}')

  GITLAB_GROUP_ID=$(curl -sS -H "PRIVATE-TOKEN: $GITLAB_API_TOKEN" "$GITLAB_API_URL/groups?top_level_only=true" | jq "map(select(.path == \"$GITLAB_GROUP\")) | .[0].id")
  if [ "$GITLAB_GROUP_ID" = "null" ];then
    echo "Creating Gitlab group $GITLAB_GROUP..."
    GITLAB_GROUP_ID=$(curl -sS -X POST \
      -H "PRIVATE-TOKEN: $GITLAB_API_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"name\": \"$GITLAB_GROUP_FULLNAME\", \"path\": \"$GITLAB_GROUP\", \"auto_devops_enabled\": \"false\", \"project_creation_level\": \"developer\", \"visibility\": \"internal\"}" \
      "$GITLAB_API_URL/groups" | jq .id)
    echo "Gitlab group $GITLAB_GROUP created (id: $GITLAB_GROUP_ID)."
    curl -sS -X POST \
      -H "PRIVATE-TOKEN: $GITLAB_API_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"user_id\": \"$GITLAB_JENKINS_USER_ID,$GITLAB_USER_ID\", \"access_level\": \"50\"}" \
      "$GITLAB_API_URL/groups/$GITLAB_GROUP_ID/members" | jq .status
  else
    echo "Gitlab group $GITLAB_GROUP already exists (id: $GITLAB_GROUP_ID)!"
  fi
  
  GITLAB_PROJECT_ID=$(curl -sS -H "PRIVATE-TOKEN: $GITLAB_API_TOKEN" "$GITLAB_API_URL/projects" | jq "map(select(.path == \"$GITLAB_PROJECT\")) | .[0].id")
  if [ "$GITLAB_PROJECT_ID" = "null" ];then
    echo "Creating Gitlab project $GITLAB_PROJECT..."
    GITLAB_PROJECT_ID=$(curl -sS -X POST \
      -H "PRIVATE-TOKEN: $GITLAB_API_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"name\": \"$GITLAB_PROJECT_FULLNAME\", \"path\": \"$GITLAB_PROJECT\", \"namespace_id\": \"$GITLAB_GROUP_ID\", \"import_url\": \"$SOURCE_GIT_URL\", \"visibility\": \"internal\", \"auto_devops_enabled\": \"false\", \"default_branch\": \"main\", \"issues_enabled\": \"true\", \"wiki_enabled\": \"true\"}" \
      "$GITLAB_API_URL/projects" | jq .)
    echo "Gitlab project $GITLAB_PROJECT created (id: $GITLAB_PROJECT_ID)."
  else
    echo "Gitlab project $GITLAB_PROJECT already exists (id: $GITLAB_PROJECT_ID)!"
  fi
done
