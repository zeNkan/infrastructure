
source "vmware-iso" "esxi" {
  # ESXI Configuration 
  remote_username  = "${var.esxi_username}"
  remote_password  = "${var.esxi_password}"
  remote_host      = "${var.esxi_host}"
  remote_type      = "esx5"
  remote_datastore = "${var.esxi_datastore}"

  # Provisioning Configuration
  ssh_username = "${var.ssh_username}"
  ssh_password = "${var.ssh_password}"
  communicator = "ssh"
  ssh_pty      = "true"
  ssh_timeout  = "60m"

  # HTTP to Fetch Provisioning scripts
  http_directory      = "."
  shutdown_command    = "sudo -S /usr/sbin/shutdown -h now"
  tools_upload_flavor = "linux"
  boot_command        = ["<tab> text net.ifnames=0 biosdevname=0 inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/scripts/atomic-kickstart.cfg<enter><wait>"]
  iso_checksum        = "${var.iso_checksum}"
  iso_url             = "${var.iso_url}"

  # Hardware Definition
  boot_wait       = "7s"
  cores           = 2
  disk_size       = 50000
  disk_type_id    = "zeroedthick"
  format          = "vmx"
  guest_os_type   = "centos8-64"
  headless        = false
  keep_registered = false
  memory          = 10240
  skip_compaction = true
  vm_name         = "${var.template_name}"
  vmdk_name       = "${var.template_name}"
  vmx_data = {
    "ethernet0.addressType"            = "generated"
    "ethernet0.generatedAddressOffset" = "0"
    "ethernet0.networkName"            = "${var.esxi_portgroup}"
    "ethernet0.present"                = "TRUE"
    "ethernet0.startConnected"         = "TRUE"
    "ethernet0.wakeOnPcktRcv"          = "FALSE"

  }
  vmx_data_post = {
    "ethernet0.virtualDev" = "vmxnet3"
  }

  # VNC Configuration
  vnc_over_websocket = "true"
  # In Case of self-signed cert for esxi host
  insecure_connection = "true"

  # Disconnect CD-rom when exporting the finished disk
  ovftool_options = ["--noImageFiles"]
  
  # this path SHOULD NOT start or end with / it will fuck things up
  remote_output_directory = "Packer/baseline"
  skip_export = true
}

build {
  sources = ["sources.vmware-iso.esxi"]

  provisioner "shell" {
    execute_command   = "{{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    expect_disconnect = true
    pause_before      = "5s"
    script            = "scripts/open-vm-tools-install.sh"
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    script          = "scripts/epel-install.sh"
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    script          = "scripts/ansible-install.sh"
  }
}
