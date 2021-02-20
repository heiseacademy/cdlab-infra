FROM debian:buster-slim

# Labels
LABEL maintainer="birk@pingworks.de" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.name="birka/ansible" \
    org.label-schema.description="Ansible inside Docker" \
    org.label-schema.url="https://github.com/birka/docker-ansible" \
    org.label-schema.vcs-url="https://github.com/birka/docker-ansible" \
    org.label-schema.vendor="Alexander Birk" \
    org.label-schema.docker.cmd="docker run --rm -it -v $(pwd):/ansible -v ~/.ssh/id_rsa:/root/id_rsa birka/ansible:2.10.4"

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y gnupg2 python3-pip sshpass git openssh-client && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean
    
RUN python3 -m pip install --upgrade pip cffi && \
    pip install ansible-base==2.10.4 ansible==2.10.4 && \
    pip install mitogen ansible-lint jmespath && \
    pip install --upgrade pywinrm && \
    ln -s /usr/bin/python3 /usr/bin/python

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
