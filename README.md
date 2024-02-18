# Overview

Packer and Vagrant files to create a pseudo-disconnected OpenShift lab using libvirt.

# Prerequisites

- A host machine with at least 18 vCPUs, 72GB RAM and 800GB Disk Space available.
- [libvirt](https://wiki.archlinux.org/title/libvirt)
- [vagrant-libvirt](https://vagrant-libvirt.github.io/vagrant-libvirt/)
- [Docker](https://docs.docker.com/engine/install/)
- [Vagrant](https://developer.hashicorp.com/vagrant/docs/installation)

# Environment Overview

## Networking

![libvirt networking](./doc/libvirt%20networking.png "libvirt networking")

# Creating Environment

## Create Pull Secret JSON

Download your [OpenShift pull secret](https://console.redhat.com/openshift/install/pull-secret) and create the file pull-secret.json in the openshift directory of this repository (./openshift/pull-secret.json)

## Mirror Registry VM Creation

The below will create the Mirror Registry VM, which is required for Ansible preparation.

```bash
vagrant up
```

The OpenShift nodes will not be started here (they're configured in the Vagrantfile with `autostart: false`), because they require outputs from the mirror process before being able to boot.

## Ansible Configuration

```bash
python3 -m venv venv # Create virtual environment if it doesn't already exist
source venv/bin/activate
pip3 install -r requirements.txt
ansible-galaxy install -r requirements.yml
ansible-playbook playbooks/openshift-lab-disconnected.yml -D
```

## OpenShift VM Creation

After Ansible has run the OpenShift nodes can be booted.

```bash
vagrant up bootstrap master01 master02 master03 worker01 worker02
```

## Configure DNS

If you want to be able to connect to the environment using DNS, you will need to configure local DNS.  
The quick and easy way to do this is via /etc/hosts, by appending lines similar to the below:

```
# OpenShift Vagrant Lab
10.0.0.2 api.openshift.vagrant api-int.openshift.vagrant apps.openshift.vagrant mirrorregistry.openshift.vagrant
10.0.0.11 bootstrap.openshift.vagrant
10.0.0.21 master01.openshift.vagrant
10.0.0.22 master02.openshift.vagrant
10.0.0.23 master03.openshift.vagrant
10.0.0.31 worker01.openshift.vagrant
10.0.0.32 worker02.openshift.vagrant
```

## Monitor Environment

After bringing up the OpenShift nodes, you can monitor the install progress using the following:

1. Set the path to the generated kubeconfig file as the environment variable `KUBECONFIG` - `export KUBECONFIG="./openshift/install/auth/kubeconfig"`
2. Browse to [the HAProxy stats page](http://10.0.0.2:9001/) to view whether nodes are reachable from HAProxy.
3. Monitor the bootstrap process with `./openshift/tools/openshift-install --dir ./openshift/install/ wait-for bootstrap-complete`  
   Remember to clean up the bootstrap node (`vagrant destroy -f bootstrap`) once it is no longer needed.
4. Monitor node status with `./openshift/tools/oc get nodes`
5. Monitor worker node CSR status with `./openshift/tools/oc get csr | grep Pending`  
   To approve all pending, run `./openshift/tools/oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs --no-run-if-empty ./openshift/tools/oc adm certificate approve`.  
   You might need to complete this twice. It's worth double checking whether there are additional pending certificates after initial approvals.
6. Monitor the status of the cluster operators with `./openshift/tools/oc get clusteroperators`.
   All of the operators should be Available, not progressing and not degraded.
7. Monitor the status of the cluster installation with `./openshift/tools/openshift-install --dir ./openshift/install/ wait-for install-complete` 
8. Disable the default OperatorHub sources with `./openshift/tools/oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'`
9. Confirm the status of all pods with `./openshift/tools/oc get pods --all-namespaces`

If you need to, you can SSH to the nodes using the SSH key at the l./openshift/tools/ocation specified with `install_ssh_key` (defaults to `~/.ssh/id_rsa.pub`).  
For example:

```bash
ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking no" core@bootstrap.openshift.vagrant # Bootstrap node
ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking no" core@master01.openshift.vagrant # Master node
ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking no" core@worker01.openshift.vagrant # Worker node
```

# Working with the environment

After a cluster has been installed, you can interact with it via either the web console or the Kubernetes API.  
The credentials for the web console are located in the file [./openshift/install/auth/kubeadmin-password](./openshift/install/auth/kubeadmin-password).  
The credentials for the Kubernetes API are located in the file [./openshift/install/auth/kubeconfig](./openshift/install/auth/kubeconfig).

# Shutdown and Restart

After initial provisioning, the cluster can be [gracefully shutdown](https://docs.openshift.com/container-platform/4.14/backup_and_restore/graceful-cluster-shutdown.html) completing the following:

1. Mark all nodes as unschedulable with `for node in $(./openshift/tools/oc get nodes -o jsonpath='{.items[*].metadata.name}'); do echo ${node} ; ./openshift/tools/oc adm cordon ${node} ; done`.
2. Evacuate all pods with `for node in $(./openshift/tools/oc get nodes -l node-role.kubernetes.io/worker -o jsonpath='{.items[*].metadata.name}'); do echo ${node} ; ./openshift/tools/oc adm drain ${node} --delete-emptydir-data --ignore-daemonsets=true --timeout=15s ; done`.
3. Shutdown the OpenShift nodes with `for node in $(./openshift/tools/oc get nodes -o jsonpath='{.items[*].metadata.name}'); do ./openshift/tools/oc debug node/${node} -- chroot /host shutdown -h 1; done`
4. Shutdown all VMs with `vagrant halt`.

The cluster can then be [gracefully restarted](https://docs.openshift.com/container-platform/4.14/backup_and_restore/graceful-cluster-restart.html) by completing the following:

1. Powering back on the mirrorregistry and OpenShift node VMs with `vagrant up mirrorregistry master01 master02 master03 worker01 worker02`
v
