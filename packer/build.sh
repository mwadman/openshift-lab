#!/usr/bin/env bash

curl -s -o ./vagrant/vagrant.pub.rsa https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub.rsa
curl -s -o ./vagrant/vagrant.pub.ed25519 https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub.ed25519

sudo docker run --rm --name butane \
                --volume ${PWD}:/pwd --workdir /pwd \
                quay.io/coreos/butane:release \
                --files-dir /pwd/vagrant/ --pretty --strict --output ./http/ignition.json ./butane.yml

packer init rhcos_qemu.pkr.hcl
packer build rhcos_qemu.pkr.hcl
