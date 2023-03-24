# -*- mode: ruby -*-
# vi: set ft=ruby :
require_relative 'vagrant_secrets.rb'
include Secrets
IP_NET = Secrets::NODE_NETWORK
Vagrant.configure("2") do |config|

  config.vm.provision :shell, path: "provisioning/commons.sh",
    env: {
          "USER_NAME" => Secrets::USER_NAME,
          "USER_PWD" => Secrets::USER_PWD
        }
  config.vm.define "k8s-cp" do |cp|
    cp.vm.box = "generic/ubuntu2204"
    cp.vm.hostname="k8s-cp"
    cp.vm.network "private_network",
      :ip => IP_NET + "10",
      :libvirt__network_name => "virt-k8s",
      :libvirt__network_address => IP_NET + "0"
    cp.vm.provision :shell, path: "provisioning/control-plane.sh",
      env: {
            "USER_NAME" => Secrets::USER_NAME,
            "PODS_CIDR" => Secrets::PODS_CIDR,
            "DOCKER_SERVER" => Secrets::DOCKER_SERVER,
            "DOCKER_USER" => Secrets::DOCKER_USER,
            "DOCKER_PWD" => Secrets::DOCKER_PWD,
            "DOCKER_EMAIL" => Secrets::DOCKER_EMAIL
           }
    cp.vm.synced_folder "./", "/vagrant", type: "nfs", nfs_udp: false, nfs_version: 4
    cp.vm.provider :libvirt do |domain|
      domain.default_prefix = ""
      domain.storage_pool_name = "images"
      domain.memory = 8192
      domain.cpus = 4
      domain.autostart = true
    end
  end

  (1..3).each do |i|
    config.vm.define "k8s-node#{i}" do |node|
      node.vm.box = "generic/ubuntu2204"
      node.vm.hostname="k8s-node#{i}"
      node.vm.network "private_network",
      :ip => IP_NET + "#{10 + i}",
      :libvirt__network_name => "virt-k8s",
      :libvirt__network_address => IP_NET + "0"
      node.vm.provision :shell, path: "provisioning/node.sh",
        env: {
              "USER_NAME" => Secrets::USER_NAME
             }
      node.vm.synced_folder "./", "/vagrant", type: "nfs", nfs_udp: false, nfs_version: 4
      node.vm.provider :libvirt do |domain|
        domain.default_prefix = ""
        domain.storage_pool_name = "images"
        domain.memory = 8192
        domain.cpus = 8
        domain.autostart = true
      end
    end
  end
end

