#!/bin/bash

# Install Ansible repository.
dnf install -y python3-pip python3-dnf

# Install Ansible.
dnf install -y ansible-core
