#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Get the IP address
export internalip=`ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`

echo This VM has IP address: $internalip

until [ -f /vagrant/configs/admin.conf ]
do
  echo "admin.conf not found. Waiting for 5s ..."
  sleep 5
done

echo Copying credentials to /home/vagrant ...
mkdir -p /home/vagrant/.kube
cp -i /vagrant/configs/admin.conf /home/vagrant/.kube/config
chown -R $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube
echo Copying credentials to /home/${USER_NAME} ...
mkdir -p /home/${USER_NAME}/.kube
cp -i /vagrant/configs/admin.conf /home/${USER_NAME}/.kube/config
chown -R $(id -u ${USER_NAME}):$(id -g ${USER_NAME}) /home/${USER_NAME}/.kube

# Join cluster
until [ -f /vagrant/configs/join.sh ]
do
  echo "join.sh not found. Waiting for 5s ..."
  sleep 5
done
chmod +x /vagrant/configs/join.sh
/vagrant/configs/join.sh

