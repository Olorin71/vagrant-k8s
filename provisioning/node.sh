#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Get the IP address
export internalip=`ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`

echo This VM has IP address: $internalip

echo Copying credentials to /home/vagrant ...
mkdir -p /home/vagrant/.kube
cp -i /vagrant/configs/admin.json /home/vagrant/.kube/config
chown -R $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube
echo Copying credentials to /home/${USER_NAME} ...
mkdir -p /home/${USER_NAME}/.kube
cp -i /vagrant/configs/admin.json /home/${USER_NAME}/.kube/config
chown -R $(id -u ${USER_NAME}):$(id -g ${USER_NAME}) /home/${USER_NAME}/.kube

# Join cluster
until [ -f /vagrant/configs/join.sh ]
do
  echo "join.sh not found. Waiting for 5s ..."
  sleep 5
done
chmod +x /vagrant/configs/join.sh
/vagrant/configs/join.sh

