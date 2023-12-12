Vagrant.configure("2") do |config|

  config.vagrant.plugins = {
    "vagrant-libvirt" => {
      "version" => "0.12.2"
    }
  }

  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = "kvm"
    libvirt.nested = true
    libvirt.management_network_mode = "none" # Only the mirror registry should have routing to the internet
    libvirt.management_network_domain = "management.vagrant"
  end

  config.vm.synced_folder '.', '/vagrant', disabled: true # Disable shared folder

  # https://docs.openshift.com/container-platform/4.14/installing/disconnected_install/installing-mirroring-creating-registry.html
  config.vm.define "mirrorregistry" do |device|
    device.vm.box = "rockylinux/9" # Doesn't use LVM so easier to resize
    device.vm.hostname = "mirrorregistry"
    device.vm.network :private_network,
      :type => "dhcp",
      :ip => "172.16.0.10",
      :libvirt__network_name => "vagrant-nat",
      :libvirt__network_address => "172.16.0.0",
      :libvirt__netmask => "255.255.255.0",
      :libvirt__domain_name => "nat.vagrant",
      :libvirt__forward_mode => "nat"
    device.vm.provider "libvirt" do |libvirt|
      libvirt.memory = 8192
      libvirt.cpus = 2
      libvirt.machine_virtual_size = 400
    end
  end

  # https://docs.openshift.com/container-platform/4.14/installing/installing_bare_metal/installing-bare-metal.html#installation-minimum-resource-requirements_installing-bare-metal
  config.vm.define "bootstrap" do |device|
    device.vm.box = "packer_rhcos_qemu_libvirt_amd64"
    device.vm.box_url = "file://./packer/output/packer_rhcos_qemu_libvirt_amd64.box"
    device.vm.hostname = "bootstrap"
    device.vm.provider "libvirt" do |libvirt|
      libvirt.memory = 16384
      libvirt.cpus = 4
      libvirt.machine_virtual_size = 100
    end
  end
  # config.vm.define "control01" do |device|
  #   device.vm.box = "packer_rhcos_qemu_libvirt_amd64"
  #   device.vm.box_url = "file://./packer/output/packer_rhcos_qemu_libvirt_amd64.box"
  #   device.vm.hostname = "control01"
  #   device.vm.provider "libvirt" do |libvirt|
  #     libvirt.memory = 16384
  #     libvirt.cpus = 4
  #     libvirt.machine_virtual_size = 100
  #   end
  # end
  # config.vm.define "control02" do |device|
  #   device.vm.box = "packer_rhcos_qemu_libvirt_amd64"
  #   device.vm.box_url = "file://./packer/output/packer_rhcos_qemu_libvirt_amd64.box"
  #   device.vm.hostname = "control02"
  #   device.vm.provider "libvirt" do |libvirt|
  #     libvirt.memory = 16384
  #     libvirt.cpus = 4
  #     libvirt.machine_virtual_size = 100
  #   end
  # end
  # config.vm.define "control03" do |device|
  #   device.vm.box = "packer_rhcos_qemu_libvirt_amd64"
  #   device.vm.box_url = "file://./packer/output/packer_rhcos_qemu_libvirt_amd64.box"
  #   device.vm.hostname = "control03"
  #   device.vm.provider "libvirt" do |libvirt|
  #     libvirt.memory = 16384
  #     libvirt.cpus = 4
  #     libvirt.machine_virtual_size = 100
  #   end
  # end
  # config.vm.define "worker01" do |device|
  #   device.vm.box = "packer_rhcos_qemu_libvirt_amd64"
  #   device.vm.box_url = "file://./packer/output/packer_rhcos_qemu_libvirt_amd64.box"
  #   device.vm.hostname = "worker01"
  #   device.vm.provider "libvirt" do |libvirt|
  #     libvirt.memory = 8192
  #     libvirt.cpus = 2
  #     libvirt.machine_virtual_size = 100
  #   end
  # end
  # config.vm.define "worker02" do |device|
  #   device.vm.box = "packer_rhcos_qemu_libvirt_amd64"
  #   device.vm.box_url = "file://./packer/output/packer_rhcos_qemu_libvirt_amd64.box"
  #   device.vm.hostname = "worker02"
  #   device.vm.provider "libvirt" do |libvirt|
  #     libvirt.memory = 8192
  #     libvirt.cpus = 2
  #     libvirt.machine_virtual_size = 100
  #   end
  # end
end
