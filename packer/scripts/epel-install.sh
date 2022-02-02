#!/bin/bash

# Install Ansible repository.
dnf update -y && dnf upgrade -y
dnf config-manager --set-enabled crb
dnf install -y \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm

