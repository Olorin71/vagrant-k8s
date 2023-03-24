#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

if id "${USER_NAME}" &>/dev/null; then
  echo "User ${USER_NAME} already exist."
else
  adduser -gecos "" --disabled-password ${USER_NAME}
  echo -e "${USER_PWD}\n${USER_PWD}" | passwd ${USER_NAME}
  usermod -aG sudo ${USER_NAME}
  echo "User ${USER_NAME} created."
fi

swapActive="$(cat /proc/swaps | grep swap.img)"
if [ ! -z "$swapActive" ]; then
  echo "disable swap due to kubelet"
  swapoff -a
  sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
else
  echo "swap already disabled."
fi

echo "Install  prerequisites"
apt-get update
apt-get install -y apt-transport-https ca-certificates wget curl gnupg lsb-release

if [ -f "/etc/modules-load.d/k8s.conf" ]; then
  echo "Overlay and br_netfilter modules already activated."
else
  echo "Activate overlay and br_netfilter modules"
  cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

  sudo modprobe overlay
  sudo modprobe br_netfilter
fi

# sysctl params required by setup, params persist across reboots
if [ -f "/etc/sysctl.d/10-k8s.conf" ]; then
  echo "sysctl params already updated."
else
  echo "Update sysctl params"
  cat <<EOF | sudo tee /etc/sysctl.d/10-k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

  # Apply sysctl params without reboot
  sysctl --system
fi

##install containerd

echo "Get and unpack containerd"
wget https://github.com/containerd/containerd/releases/download/v1.7.0/containerd-1.7.0-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-1.7.0-linux-amd64.tar.gz

echo "Get and unpack runc"
wget https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

echo "Get and unpack cni-plugins"
wget https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.2.0.tgz

echo "create default containerd config file"
mkdir -p /etc/containerd/
containerd config default | sudo tee /etc/containerd/config.toml

echo "activate systemd as cgroup driver"
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

echo "Get containerd systemd service definition file and enable it"
curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /etc/systemd/system/containerd.service

systemctl daemon-reload
systemctl start containerd
systemctl enable containerd

# install helm, kubeadm, kubelet and kubectl
echo "add k8s and helm to sources"
curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

echo "Install kubeadm, kubelet and kubectl and helm"
apt-get update
apt-get install -y kubelet kubeadm kubectl helm
# These instruction excludes all Kubernetes packages from any system upgrades. This is because kubeadm and Kubernetes require special attention to upgrade.
# see https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/
apt-mark hold kubelet kubeadm kubectl

# Get the IP address
export internal_ip=`ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`

echo This VM has IP address: $internal_ip

cat > /etc/default/kubelet << EOF
KUBELET_EXTRA_ARGS=--node-ip=$internal_ip
EOF
