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

  config.vm.define "mirrorregistry" do |device|
    device.vm.hostname = "mirrorregistry"
    device.vm.network :private_network,
      :type => "dhcp",
      :ip => "10.0.0.10",
      :hostname => true,
      :libvirt__network_name => "vagrant-none",
      :libvirt__network_address => "10.0.0.0",
      :libvirt__netmask => "255.255.255.0",
      :libvirt__domain_name => "none.vagrant",
      :libvirt__forward_mode => "none"
    device.vm.network :private_network,
      :type => "dhcp",
      :ip => "172.16.0.10",
      :libvirt__network_name => "vagrant-nat",
      :libvirt__network_address => "172.16.0.0",
      :libvirt__netmask => "255.255.255.0",
      :libvirt__domain_name => "nat.vagrant",
      :libvirt__forward_mode => "nat"
    device.vm.provider "libvirt" do |domain|
      domain.memory = 1024
      domain.cpus = 1
    end
  end
  config.vm.define "disconnected" do |device|
    device.vm.hostname = "disconnected"
    device.vm.network :private_network,
      :type => "dhcp",
      :ip => "10.0.0.11",
      :hostname => true,
      :libvirt__network_name => "vagrant-none",
      :libvirt__network_address => "10.0.0.0",
      :libvirt__netmask => "255.255.255.0",
      :libvirt__domain_name => "none.vagrant",
      :libvirt__forward_mode => "none"
    device.vm.provider "libvirt" do |domain|
      domain.memory = 1024
      domain.cpus = 1
    end
  end
end
