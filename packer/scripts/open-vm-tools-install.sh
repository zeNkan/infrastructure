#!/bin/bash

# rpm-ostree install open-vm-tools perl
dnf install -y open-vm-tools
systemctl reboot
