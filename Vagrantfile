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
    libvirt.management_network_domain = "mgmt.vagrant"
  end

  config.vm.synced_folder '.', '/vagrant', disabled: true # Disable shared folder

  # https://docs.openshift.com/container-platform/4.14/installing/disconnected_install/installing-mirroring-creating-registry.html
  config.vm.define "mirrorregistry" do |device|
    device.vm.box = "rockylinux/9" # Doesn't use LVM so easier to resize
    device.vm.hostname = "mirrorregistry"
    device.vm.network :private_network,
      :type => "dhcp",
      :libvirt__forward_mode => "nat",
      :libvirt__network_name => "vagrant-nat",
      :libvirt__network_address => "172.16.0.0",
      :libvirt__netmask => "255.255.255.0",
      :libvirt__domain_name => "nat.vagrant",
      :libvirt__adapter => 1, # eth1
      :ip => "172.16.0.10"
    device.vm.network :private_network,
      :libvirt__forward_mode => "none",
      :libvirt__dhcp_enabled => false,
      :libvirt__network_name => 'vagrant-openshift',
      :libvirt__network_address => "10.0.0.0",
      :libvirt__netmask => "255.255.255.0",
      :libvirt__domain_name => "openshift.vagrant",
      :libvirt__adapter => 2, # eth2
      :libvirt__mac => "52:54:00:00:00:02" # 10.0.0.2
    device.vm.provider "libvirt" do |libvirt|
      libvirt.memory = 8192
      libvirt.cpus = 2
      libvirt.machine_virtual_size = 400
    end
  end

  # https://docs.openshift.com/container-platform/4.14/installing/installing_bare_metal/installing-bare-metal.html#installation-minimum-resource-requirements_installing-bare-metal
  config.vm.define "bootstrap", autostart: false do |device|
    device.vm.hostname = "bootstrap"
    device.vm.network :private_network,
      :libvirt__forward_mode => "none",
      :libvirt__dhcp_enabled => false,
      :libvirt__network_name => 'vagrant-openshift',
      :libvirt__network_address => "10.0.0.0",
      :libvirt__netmask => "255.255.255.0",
      :libvirt__domain_name => "openshift.vagrant",
      :libvirt__adapter => 1,
      :libvirt__mac => "52:54:00:00:00:11" # 10.0.0.11
    device.vm.provider "libvirt" do |libvirt|
      libvirt.memory = 16384
      libvirt.cpus = 4
      libvirt.boot 'hd'
      libvirt.boot 'network'
      libvirt.storage :file, :size => '100G'
    end
  end
  (1..3).each do |node_num|
    config.vm.define "control0#{node_num}", autostart: false do |device|
      device.vm.hostname = "control0#{node_num}"
      device.vm.network :private_network,
        :libvirt__forward_mode => "none",
        :libvirt__dhcp_enabled => false,
        :libvirt__network_name => 'vagrant-openshift',
        :libvirt__network_address => "10.0.0.0",
        :libvirt__netmask => "255.255.255.0",
        :libvirt__domain_name => "openshift.vagrant",
        :libvirt__adapter => 1,
        :libvirt__mac => "52:54:00:00:00:2#{node_num}" # 10.0.0.2X
      device.vm.provider "libvirt" do |libvirt|
        libvirt.memory = 16384
        libvirt.cpus = 4
        libvirt.boot 'hd'
        libvirt.boot 'network'
        libvirt.storage :file, :size => '100G'
      end
    end
  end
  (1..2).each do |node_num|
    config.vm.define "worker0#{node_num}", autostart: false do |device|
      device.vm.hostname = "control0#{node_num}"
      device.vm.network :private_network,
        :libvirt__forward_mode => "none",
        :libvirt__dhcp_enabled => false,
        :libvirt__network_name => 'vagrant-openshift',
        :libvirt__network_address => "10.0.0.0",
        :libvirt__netmask => "255.255.255.0",
        :libvirt__domain_name => "openshift.vagrant",
        :libvirt__adapter => 1,
        :libvirt__mac => "52:54:00:00:00:3#{node_num}" # 10.0.0.3X
      device.vm.provider "libvirt" do |libvirt|
        libvirt.memory = 8192
        libvirt.cpus = 2
        libvirt.boot 'hd'
        libvirt.boot 'network'
        libvirt.storage :file, :size => '100G'
      end
    end
  end
end
