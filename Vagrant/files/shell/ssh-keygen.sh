#!/bin/bash

PUBLIC_SSH_KEY=$(cat "/vagrant/files/dot/ssh/id_rsa.pub")

echo " ***************************************************************************** "
echo 'Adding generated key to /root/.ssh/id_rsa'
echo 'Adding generated key to /root/.ssh/id_rsa.pub'
echo 'Adding generated key to /root/.ssh/authorized_keys'
echo " ***************************************************************************** "

mkdir -p /root/.ssh

cp "/vagrant/files/dot/ssh/id_rsa" '/root/.ssh/'
cp "/vagrant/files/dot/ssh/id_rsa.pub" '/root/.ssh/'

if [[ ! -f '/root/.ssh/authorized_keys' ]] || ! grep -q "${PUBLIC_SSH_KEY}" '/root/.ssh/authorized_keys'; then
    cat "/vagrant/files/dot/ssh/id_rsa.pub" >> '/root/.ssh/authorized_keys'
fi

chown -R root '/root/.ssh'
chgrp -R root '/root/.ssh'
chmod 700 '/root/.ssh'
chmod 644 '/root/.ssh/id_rsa.pub'
chmod 600 '/root/.ssh/id_rsa'
chmod 600 '/root/.ssh/authorized_keys'

echo " ***************************************************************************** "
echo "Adding hosts to /root/.ssh/known_hosts"
echo " ***************************************************************************** "

cat "/vagrant/files/dot/ssh/known_hosts" > "/root/.ssh/known_hosts"
chmod 600 "/root/.ssh/known_hosts"

VAGRANT_SSH_FOLDER="/home/vagrant/.ssh";

mkdir -p "${VAGRANT_SSH_FOLDER}"

echo " ***************************************************************************** "
echo "Adding generated key to ${VAGRANT_SSH_FOLDER}/id_rsa"
echo "Adding generated key to ${VAGRANT_SSH_FOLDER}/id_rsa.pub"
echo "Adding generated key to ${VAGRANT_SSH_FOLDER}/authorized_keys"
echo " ***************************************************************************** "

cp "/vagrant/files/dot/ssh/id_rsa" "${VAGRANT_SSH_FOLDER}/id_rsa"
cp "/vagrant/files/dot/ssh/id_rsa.pub" "${VAGRANT_SSH_FOLDER}/id_rsa.pub"

if [[ ! -f "${VAGRANT_SSH_FOLDER}/authorized_keys" ]] || ! grep -q "${PUBLIC_SSH_KEY}" "${VAGRANT_SSH_FOLDER}/authorized_keys"; then
    cat "/vagrant/files/dot/ssh/id_rsa.pub" >> "${VAGRANT_SSH_FOLDER}/authorized_keys"
fi

chown -R vagrant "${VAGRANT_SSH_FOLDER}"
chgrp -R vagrant "${VAGRANT_SSH_FOLDER}"
chmod 700 "${VAGRANT_SSH_FOLDER}"
chmod 644 "${VAGRANT_SSH_FOLDER}/id_rsa.pub"
chmod 600 "${VAGRANT_SSH_FOLDER}/id_rsa"
chmod 600 "${VAGRANT_SSH_FOLDER}/authorized_keys"

passwd -d vagrant >/dev/null
