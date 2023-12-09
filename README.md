# Overview

Packer and Vagrant files to create a pseudo-disconnected OpenShift lab using libvirt.

# Prerequisites

- [libvirt](https://wiki.archlinux.org/title/libvirt)
- [vagrant-libvirt](https://vagrant-libvirt.github.io/vagrant-libvirt/)
- [Docker](https://docs.docker.com/engine/install/)
- [Packer](https://developer.hashicorp.com/packer/install)
- [Vagrant](https://developer.hashicorp.com/vagrant/docs/installation)

# Environment Overview

## Networking

![libvirt networking](./doc/libvirt%20networking.png "libvirt networking")

# Running Environment

## Packer Box Creation

Because I don't feel comfortable uploading a Red Hat CoreOS image [for everyone to download](https://app.vagrantup.com/boxes/search), you will first need to build an image yourself.  
To do so, change into the `packer` directory and run `build.sh`:

```bash
cd packer
./build.sh
```

## Vagrant Environment Creation

```bash
vagrant up
```
