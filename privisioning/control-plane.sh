#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Get the IP address
internalip=`ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`

echo This VM has IP address: $internalip
# Set up Kubernetes
NODENAME=$(hostname -s)
kubeadm init --apiserver-cert-extra-sans=$internalip --node-name=$NODENAME --pod-network-cidr=${PODS_CIDR} --apiserver-advertise-address=$internalip

# Copy up admin creds to Vagrant share
echo Copying credentials to /vagrant/configs/ ...
mkdir -p /vagrant/configs/
cp -i /etc/kubernetes/admin.conf /vagrant/configs/admin.conf
# Set up admin creds for the vagrant user
echo Copying credentials to /home/vagrant ...
sudo mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube
# Set up admin creds for user ${USER_NAME}
echo Copying credentials to /home/${USER_NAME} ...
mkdir -p /home/${USER_NAME}/.kube
cp -i /etc/kubernetes/admin.conf /home/${USER_NAME}/.kube/config
chown -R alex:alex /home/${USER_NAME}/.kube

export KUBECONFIG=/etc/kubernetes/admin.conf
export digest=`openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'`
export token=`kubeadm token list | grep "default bootstrap" | awk '{print $1}'`


echo  "create join.sh"
mkdir -p /vagrant/configs
echo "kubeadm join --token $token $internalip:6443 --discovery-token-ca-cert-hash sha256:$digest" > /vagrant/configs/join.sh
chmod +x /vagrant/configs/join.sh

echo "install network add on: calico"
helm repo add projectcalico https://docs.tigera.io/calico/charts
kubectl create namespace tigera-operator
helm install calico projectcalico/tigera-operator --version v3.25.0 --namespace tigera-operator
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calicoctl.yaml
alias calicoctl="kubectl exec -i -n kube-system calicoctl -- /calicoctl"

# Install Metrics Server
echo "Install metrics server helm chart"
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server

echo "add docker registry"
kubectl create secret docker-registry docker-private --docker-server=${DOCKER_SERVER} --docker-username=${DOCKER_USER} --docker-password=${DOCKER_PWD} --docker-email=${DOCKER_EMAIL}
kubectl get secrets docker-private


