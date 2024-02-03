# Overview

Packer and Vagrant files to create a pseudo-disconnected OpenShift lab using libvirt.

# Prerequisites

- A host machine with at least 18 vCPUs, 72GB RAM and 800GB Disk Space available.
- [libvirt](https://wiki.archlinux.org/title/libvirt)
- [vagrant-libvirt](https://vagrant-libvirt.github.io/vagrant-libvirt/)
- [Docker](https://docs.docker.com/engine/install/)
- [Packer](https://developer.hashicorp.com/packer/install)
- [Vagrant](https://developer.hashicorp.com/vagrant/docs/installation)

# Environment Overview

## Networking

![libvirt networking](./doc/libvirt%20networking.png "libvirt networking")

# Running Environment

## Create Pull Secret JSON

Download your [OpenShift pull secret](https://console.redhat.com/openshift/install/pull-secret) and create the file pull-secret.json at the root of this repository.

## Vagrant Environment Creation

```bash
vagrant up
```

## Ansible Configuration

```bash
python3 -m venv venv # Create virtual environment if it doesn't already exist
source venv/bin/activate
pip3 install -r requirements.txt
ansible-galaxy install -r requirements.yml
ansible-playbook playbooks/openshift-lab-disconnected.yml -D
```
