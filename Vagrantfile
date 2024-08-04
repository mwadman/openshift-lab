Vagrant.configure("2") do |config|

  config.vagrant.plugins = {
    "vagrant-libvirt" => {
      "version" => "0.12.2"
    }
  }

  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = "kvm"
    libvirt.nested = true
    libvirt.management_network_domain = "lab.vagrant"
    libvirt.management_network_guest_ipv6 = "no"
  end

  config.vm.synced_folder '.', '/vagrant', disabled: true # Disable shared folder

  # https://docs.openshift.com/container-platform/4.14/installing/installing_bare_metal/installing-bare-metal.html#installation-load-balancing-user-infra_installing-bare-metal
  config.vm.define "lb" do |device|
    device.vm.box = "rockylinux/9" # Doesn't use LVM so easier to resize
    device.vm.hostname = "lb"
    device.vm.provider "libvirt" do |libvirt|
      libvirt.memory = 4096
      libvirt.cpus = 2
      libvirt.machine_virtual_size = 20
      libvirt.management_network_mac = "52:54:00:00:00:10" # So we can use it in the below trigger script
    end
    # Sets static DHCP and DNS entries
    device.trigger.after [:up] do |trigger|
      trigger.info = "Running ./virsh.sh locally..."
      trigger.run = {path: "./virsh.sh"}
    end
  end

  # https://docs.openshift.com/container-platform/4.14/installing/installing_bare_metal/installing-bare-metal.html#installation-minimum-resource-requirements_installing-bare-metal
  config.vm.define "bootstrap", autostart: false do |device|
    device.vm.hostname = "bootstrap"
    device.vm.provider "libvirt" do |libvirt|
      libvirt.memory = 16384
      libvirt.cpus = 4
      libvirt.boot 'hd'
      libvirt.boot 'cdrom'
      libvirt.storage :file, :device => :cdrom, :path => File.dirname(__FILE__) + '/openshift/images/bootstrap.iso'
      libvirt.storage :file, :size => '100G'
      libvirt.management_network_mac = "52:54:00:00:00:21" # 192.168.121.21
    end
    device.ssh.username = "core"
    device.ssh.password = "vagrant"
    device.ssh.insert_key = false # https://access.redhat.com/solutions/6984064
  end
  (1..3).each do |node_num|
    config.vm.define "master0#{node_num}", autostart: false do |device|
      device.vm.hostname = "master0#{node_num}"
      device.vm.provider "libvirt" do |libvirt|
        libvirt.memory = 16384
        libvirt.cpus = 4
        libvirt.boot 'hd'
        libvirt.boot 'cdrom'
        libvirt.storage :file, :device => :cdrom, :path => File.dirname(__FILE__) + '/openshift/images/master.iso'
        libvirt.storage :file, :size => '100G'
        libvirt.storage :file, :size => '100G' # Second disk for local disk operator and ODF
        libvirt.management_network_mac = "52:54:00:00:00:3#{node_num}" # 192.168.121.3x
      end
      device.ssh.username = "core"
      device.ssh.password = "vagrant"
      device.ssh.insert_key = false # https://access.redhat.com/solutions/6984064
    end
  end
  # (1..2).each do |node_num|
  #   config.vm.define "worker0#{node_num}", autostart: false do |device|
  #     device.vm.hostname = "worker0#{node_num}"
  #     device.vm.network :private_network,
  #       :libvirt__forward_mode => "none",
  #       :libvirt__dhcp_enabled => false,
  #       :libvirt__host_ip => "10.0.0.1",
  #       :libvirt__network_name => 'vagrant-openshift',
  #       :libvirt__network_address => "10.0.0.0",
  #       :libvirt__netmask => "255.255.255.0",
  #       :libvirt__domain_name => "openshift.vagrant",
  #       :libvirt__adapter => 0,
  #       :libvirt__mac => "52:54:00:00:00:3#{node_num}" # 10.0.0.3X
  #     device.vm.provider "libvirt" do |libvirt|
  #       libvirt.memory = 8192
  #       libvirt.cpus = 2
  #       libvirt.boot 'hd'
  #       libvirt.boot 'cdrom'
  #       libvirt.storage :file, :device => :cdrom, :path => File.dirname(__FILE__) + '/openshift/images/worker.iso'
  #       libvirt.storage :file, :size => '100G'
  #       libvirt.mgmt_attach = false
  #     end
  #     device.ssh.username = "core"
  #     device.ssh.password = "vagrant"
  #     device.ssh.insert_key = false # https://access.redhat.com/solutions/6984064
  #   end
  # end
end
