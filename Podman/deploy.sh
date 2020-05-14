#!/bin/bash
apt update
 
#Add PPA repository
apt -y  install software-properties-common
add-apt-repository -y ppa:projectatomic/ppa
apt update
 
#install podman
apt -y install podman
 
#add container registries
mkdir -p /etc/containers
curl https://raw.githubusercontent.com/projectatomic/registries/master/registries.fedora -o /etc/containers/registries.conf
curl https://raw.githubusercontent.com/containers/skopeo/master/default-policy.json -o /etc/containers/policy.json
 
#test
podman run hello-world
