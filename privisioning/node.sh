#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Get the IP address
export internalip=`ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`

echo This VM has IP address: $internalip

echo Copying credentials to /home/vagrant...
sudo --user=vagrant mkdir -p /home/vagrant/.kube
cp -i /vagrant/configs/config/admin.json /home/vagrant/.kube/config
chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config


# Join cluster
until [ -f /vagrant/configs/join.sh ]
do
  echo "join.sh not found. Waiting for 5s ..."
  sleep 5
done
chmod +x /vagrant/configs/join.sh
/vagrant/configs/join.sh

