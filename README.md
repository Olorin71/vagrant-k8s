# vagrant k8s

# Secrets File (vagrant_secrets.rb)
You need a File called vagrant_secrets.rb to handle your secrets and env variables.

`NODE_NETWORK` is used to define the IPv4 addresses for the K8s nodes (only the NETWORK i.e. 10.0.0.), the last part
of the address will be generated.

`PODS_CIDR` is used to define cidr for the pods in the cluster nodes. This value is given to kubeadm on creating 
the first control plane as `--pod-network-cidr=<YOUR-PODS-CIDR>`

`USER_NAME` and `USER_PWD` are used to define a username and password to be created on each vm. 
This user will be added to sudoers.

`DOCKER_SERVER`, `DOCKER_USER`, `DOCKER_PWD` and `DOCKER_EMAIL` are used to add a private docker registry to the k8s 
cluster, if you need one.

```
module Secrets
    NODE_NETWORK = "10.172.168."
    PODS_CIDR = "172.16.0.0/16"
    USER_NAME = "username"
    USER_PWD = "password"
    DOCKER_SERVER = "your-private-docker-registry.whatever.com"
    DOCKER_USER = "registry_username"
    DOCKER_PWD = "registry_password"
    DOCKER_EMAIL = "registry_email@whatever.com"
end
```
