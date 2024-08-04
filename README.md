# OpenShift Lab

## Overview

Packer and Vagrant files to create an OpenShift lab using libvirt.  
See the `disconnected` branches for instructions on how to deploy a lab in a pseudo-disconnected state.

## Prerequisites

- A host machine with at least 20 vCPUs, 80GB RAM and 720GB Disk Space available.  
  You can reduce this to 16 vCPUs, 64GB RAM and 520GB Disk Space available by removing the worker nodes, which is documented below.
- [libvirt](https://wiki.archlinux.org/title/libvirt)
- [vagrant-libvirt](https://vagrant-libvirt.github.io/vagrant-libvirt/)
- [Docker](https://docs.docker.com/engine/install/)
- [Vagrant](https://developer.hashicorp.com/vagrant/docs/installation)

## Environment Overview

### Networking

![libvirt networking](./doc/libvirt%20networking.png "libvirt networking")

## Creating Environment

### Create Pull Secret JSON

Download your [OpenShift pull secret](https://console.redhat.com/openshift/install/pull-secret) and create the file pull-secret.json in the openshift directory of this repository (./openshift/pull-secret.json)

### Configure Worker Node Count

By default, this repository will deploy worker nodes alongside the master nodes.  
If preferred (or needed due to resource restrictions), these nodes can be removed from a deployment by:

- Commenting lines 101-127 of `./Vagrantfile`, and;
- Modifying the HAProxy configuration in `./inventory/host_vars/mirrorregistry/dnsmasq.yml` so that ports 80 and 443 are pointed at all master nodes.
- Creating an Ansible variables file for `localhost` and setting `openshift_config_control_schedulable: true` (or changing this in `./roles/openshift_config/defaults/main.yml`).

### Load Balancer VM Creation

The below will create the Load Balancer VM, which is required for Ansible preparation.

```bash
vagrant up
```

The OpenShift nodes will not be started here (they're configured in the Vagrantfile with `autostart: false`), because they require outputs from running Ansible before being able to boot.

### Ansible Setup and Run

```bash
python3 -m venv venv # Create virtual environment if it doesn't already exist
source venv/bin/activate
pip3 install -r requirements.txt
ansible-galaxy install -r requirements.yml
ansible-playbook playbooks/openshift-lab.yml -D
```

### OpenShift VM Creation

After Ansible has run the OpenShift nodes can be booted.

```bash
vagrant up bootstrap master01 master02 master03 worker01 worker02
```

### Configure DNS

If you want to be able to connect to the environment using DNS, you will need to configure local DNS.  
This configuration will depend on your local machine's DNS implementation, but when using NetworkManager you can enable dnsmasq and create a configuration file in `/etc/NetworkManager/dnsmasq.d/` similar to the below (replacing `192.168.121.1` if your vagrant-libvirt network uses a different host IP address/subnet):

```bash
server=/lab.vagrant/192.168.121.1
```

### Monitor Environment

After bringing up the OpenShift nodes, you can monitor the install progress using the following:

1. Set the path to the generated kubeconfig file as the environment variable `KUBECONFIG` - `export KUBECONFIG="./openshift/install/auth/kubeconfig"`
2. Browse to [the HAProxy stats page](http://lb.lab.vagrant:9001/) to view whether nodes are reachable from HAProxy.
3. Monitor the bootstrap process with `./openshift/tools/openshift-install --dir ./openshift/install/ wait-for bootstrap-complete`  
   Remember to clean up the bootstrap node (`vagrant destroy -f bootstrap`) once it is no longer needed.
4. Monitor node status with `./openshift/tools/oc get nodes`
5. Monitor worker node CSR status with `./openshift/tools/oc get csr | grep Pending`  
   To approve all pending, run `./openshift/tools/oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs --no-run-if-empty ./openshift/tools/oc adm certificate approve`.  
   You might need to complete this twice. It's worth double checking whether there are additional pending certificates after initial approvals.
6. Monitor the status of the cluster operators with `./openshift/tools/oc get clusteroperators`.
   All of the operators should be Available, not progressing and not degraded.
   You can run `./openshift/tools/oc get clusteroperator | grep -v "True        False         False"` to only show unhealthy operators.
7. Monitor the status of the cluster installation with `./openshift/tools/openshift-install --dir ./openshift/install/ wait-for install-complete`
8. Confirm the status of all pods with `./openshift/tools/oc get pods --all-namespaces`.
   You can run `./openshift/tools/oc get pods --all-namespaces --field-selector="status.phase!=Running,status.phase!=Succeeded"` to only show unhealthy pods.

### Troubleshooting Installation

In the case that installation is failing, you can SSH to the bootstrap node to assist in determining the cause of the failure, presuming you've reached the stage where the bootstrap VM has successfully started:

```bash
# SSH to Bootstrap VM, as per above section
vagrant ssh bootstrap # Bootstrap node
ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking no" core@bootstrap.lab.vagrant # Bootstrap node
# Become the root user and set KUBECONFIG variable
sudo su
export KUBECONFIG="./openshift/install/auth/kubeconfig"
# Run troubleshooting commands as required
journalctl -b -f -u release-image.service -u bootkube.service # Shows progress of bootstrap process
oc get clusteroperator | grep -v "True        False         False" # Displays unhealthy cluster operators
oc get pods --all-namespaces --field-selector="status.phase!=Running,status.phase!=Succeeded" # Displays unhealthy pods
# Other commands to determine state of environment
## Appending `--request-timeout=5s` can be useful during a failed install as the API may not be responsive
## Appending `-o json` provides more detail if needed
oc get nodes
oc get apiservices
oc get clusterversion
oc get machineconfigpools
```

Note that the SSH command above can be used to connect to any VM that's been deployed (e.g. master01).

## Working with the environment

After a cluster has been installed, you can interact with it via either the web console or the Kubernetes API.  
The credentials for the web console are located in the file [./openshift/install/auth/kubeadmin-password](./openshift/install/auth/kubeadmin-password).  
The credentials for the Kubernetes API are located in the file [./openshift/install/auth/kubeconfig](./openshift/install/auth/kubeconfig).

## Shutdown and Restart

After initial provisioning, the cluster can be [gracefully shutdown](https://docs.openshift.com/container-platform/4.14/backup_and_restore/graceful-cluster-shutdown.html) completing the following:

1. Mark all nodes as unschedulable with `for node in $(./openshift/tools/oc get nodes -o jsonpath='{.items[*].metadata.name}'); do echo ${node} ; ./openshift/tools/oc adm cordon ${node} ; done`.
2. Evacuate all pods with `for node in $(./openshift/tools/oc get nodes -l node-role.kubernetes.io/worker -o jsonpath='{.items[*].metadata.name}'); do echo ${node} ; ./openshift/tools/oc adm drain ${node} --delete-emptydir-data --ignore-daemonsets=true --timeout=15s ; done`.
3. Shutdown the OpenShift nodes with `for node in $(./openshift/tools/oc get nodes -o jsonpath='{.items[*].metadata.name}'); do ./openshift/tools/oc debug node/${node} -- chroot /host shutdown -h 1; done`
4. Shutdown all VMs with `vagrant halt`.

The cluster can then be [gracefully restarted](https://docs.openshift.com/container-platform/4.14/backup_and_restore/graceful-cluster-restart.html) by completing the following:

1. Powering back on the OpenShift node VMs with `vagrant up master01 master02 master03 worker01 worker02`

## Install from Scratch

To install a new cluster from scratch the following local directories need to be cleared:

- `./openshift/images/`
- `./openshift/install/`
