packer {
  required_plugins {
    qemu = {
      source = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    vagrant = {
      source = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

variable "iso_url" {
  type = string
  default = "https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/latest/rhcos-live.x86_64.iso"
}
variable "iso_checksum" {
  type = string
  default = "file:https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/latest/sha256sum.txt"
}

source "qemu" "rhcos_qemu" {
  # QEMU Builder Configuration
  disk_size = 10000 # 10GB
  memory = "1024" # Needed because CoreOS is loaded into memory
  cpu_model = "host" # https://github.com/hashicorp/packer/issues/11839
  # ISO Configuration
  iso_url = "${var.iso_url}"
  iso_checksum = "${var.iso_checksum}"
  # HTTP Directory Configuration
  http_directory = "http"
  # Shutdown Configuration
  shutdown_command = "sudo shutdown -h now"
  # Communicator Configuration
  communicator = "ssh"
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  # Boot Configuration
  boot_wait = "30s"
  boot_command = [
    "sudo coreos-installer install --offline --insecure-ignition -I http://{{ .HTTPIP }}:{{ .HTTPPort }}/ignition.json /dev/vda",
    "<enter>",
    "<wait1m>",
    "sudo reboot -h now",
    "<enter>"
  ]
}

build {
  sources = [
    "sources.qemu.rhcos_qemu"
  ]
  post-processors {
    post-processor "vagrant" {
      output = "./output/packer_{{.BuildName}}_{{.Provider}}_{{.Architecture}}.box"
    }
  }
}
