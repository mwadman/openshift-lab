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

  config.vm.box = "packer_rhcos_qemu_libvirt_amd64"
  config.vm.box_url = "file://./packer/output/packer_rhcos_qemu_libvirt_amd64.box"
  config.vm.synced_folder '.', '/vagrant', disabled: true # Disable shared folder

  # https://docs.openshift.com/container-platform/4.14/installing/disconnected_install/installing-mirroring-creating-registry.html
  config.vm.define "mirrorregistry" do |device|
    device.vm.box = "generic/rocky9"
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
      libvirt.storage :file, :size => '400G'
    end
  end
  config.vm.define "disconnected" do |device|
    device.vm.hostname = "disconnected"
    device.vm.provider "libvirt" do |libvirt|
      libvirt.memory = 1024
      libvirt.cpus = 1
    end
  end
end
