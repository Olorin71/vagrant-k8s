# vagrant k8s

# Secrets File (vagrant_secrets.rb)
You need a File called vagrant_secrets.rb to handle your secrets and env variables.

`USER_NAME` and `USER_PWD` are used to define a username and password to be created on each vm. 
This user will be added to sudoers.

`DOCKER_SERVER`, `DOCKER_USER`, `DOCKER_PWD` and `DOCKER_EMAIL` are used to add a private docker registry to the k8s 
cluster, if you need one.

```
module Secrets
  USER_NAME = "the username to be created"
  USER_PWD = "the user password"
  DOCKER_SERVER = "docker registry i.e. my.registry.example.com"
  DOCKER_USER = "docker registry user to log in with"
  DOCKER_PWD = "docker registry user password"
  DOCKER_EMAIL = "docker registry user email"
end
```
