source "vmware-vmx" "baseline" {
  vm_name = "minecraft"
  source_path = "Packer/baseline/packer-build.vmx"
  remote_username = "${var.esxi_username}"
  remote_password = "${var.esxi_password}"
  remote_host = "${var.esxi_host}"
  remote_type = "esx5"
  ssh_username = "packer"
  ssh_password = "packer"
  
  # Disconnect CD-rom when exporting the finished disk
  ovftool_options = ["--noImageFiles"]

  # VNC Configuration
  disable_vnc = true

  shutdown_command   = "sudo su root -c \"userdel -rf packer; rm /etc/sudoers.d/90-cloud-init-users; /sbin/shutdown -hP now\""

}

build {

  sources = ["sources.vmware-vmx.baseline"]

  provisioner "ansible-local" {
    playbook_file = "ansible/playbook.yml"
    role_paths = [
      "../../ansible/roles/"
    ]
    # ansible-galaxy collection installed like this because collections
    # are not supported by ansible-local yet...             no, I'm not angry..
    command           = "ansible-galaxy collection install -r /tmp/ansible-roles/requirements.yml && PYTHONUNBUFFERED=1 ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3 ANSIBLE_ROLES_PATH=\"/tmp/ansible-roles/roles:/home/kali/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:/tmp/ansible-roles:/tmp/ansible-roles/roles/roles\" ansible-playbook"
    inventory_file    = "../ansible-local/hosts"
    staging_directory = "/tmp/ansible-roles/"
    extra_arguments   = [
      "--extra-vars 'rcon=${var.minecraft_rcon}'", 
      "--extra-vars 'rcon_port=${var.minecraft_rcon_port}'",
      "--extra-vars 'jvm_ram=10G'",
      "--extra-vars 'webhook_secret=${var.webhook_secret}'"
    ]
    galaxy_file = "../../ansible/requirements.yml"
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    pause_before    = "5s"
    script          = "scripts/vmware-cleanup.sh"
  }

}
