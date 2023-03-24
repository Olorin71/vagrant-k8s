# -*- mode: ruby -*-
# vi: set ft=ruby :
require_relative 'vagrant_secrets.rb'
include Secrets

Vagrant.configure("2") do |config|

  config.vm.provision :shell, path: "common.sh",
    env: {
          "USER_NAME" => Secrets::USER_NAME,
          "USER_PWD" => Secrets::USER_PWD,
          "DOCKER_SERVER" => Secrets::DOCKER_SERVER,
          "DOCKER_USER" => Secrets::DOCKER_USER,
          "DOCKER_PWD" => Secrets::DOCKER_PWD,
          "DOCKER_EMAIL" => Secrets::DOCKER_EMAIL
        }
  config.vm.define "k8s-cp" do |vm1|
    vm1.vm.box = "generic/ubuntu2204"
    vm1.vm.hostname="k8s-cp"
    vm1.vm.provision :shell, path: "bootstrap-cp.sh",
      env: {
          "USER_NAME" => Secrets::USER_NAME,
             "USER_PWD" => Secrets::USER_PWD,
             "DOCKER_SERVER" => Secrets::DOCKER_SERVER,
             "DOCKER_USER" => Secrets::DOCKER_USER,
             "DOCKER_PWD" => Secrets::DOCKER_PWD,
             "DOCKER_EMAIL" => Secrets::DOCKER_EMAIL
           }
    vm1.vm.synced_folder "./", "/vagrant", type: "nfs", nfs_upd: false, nfs_version: 4
    vm1.vm.provider :libvirt do |domain|
      domain.default_prefix = ""
      domain.storage_pool_name = "images"
      domain.memory = 8192
      domain.cpus = 4
      domain.autostart = true
    end
  end

  (1..3).each do |i|
    config.vm.define "k8s-node#{i}" do |vm1|
      vm1.vm.box = "generic/ubuntu2204"
      vm1.vm.hostname="k8s-node#{i}"
      vm1.vm.provision :shell, path: "bootstrap-node.sh",
      env: {
            "USER_NAME" => Secrets::USER_NAME,
            "USER_PWD" => Secrets::USER_PWD
           }
      vm1.vm.synced_folder "./", "/vagrant", type: "nfs", nfs_upd: false, nfs_version: 4
      vm1.vm.provider :libvirt do |domain|
        domain.default_prefix = ""
        domain.storage_pool_name = "images"
        domain.memory = 8192
        domain.cpus = 8
        domain.autostart = true
      end
    end
  end
end

