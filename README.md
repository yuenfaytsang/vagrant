# Vagrant Project via config file 


## Requirements

The following software must be installed/present on your local machine.

  - [Vagrant](http://vagrantup.com/)
  - [VirtualBox](https://www.virtualbox.org/)

## Usage

Make sure `vagrant` and `virtualbox` are installed and available on you local system, then change into the directory containing the Vagrantfile and run:

    $ vagrant up

After a few minutes, Vagrant should spin up your Project on your local machine with virtualbox.


## Configuring local VM's

Instead of caring about the vagrant file syntax and editing the vagrant file itself, you can confgiure your boxes in a central configuration file located your Vagrant project config/config.yaml.

## Current supported customizations:
- Amount of VirtualBox VM's in your vagrant project
- VirtualBox Virtual Machine Name
- Virtual Machine private network address
- Virtual Machine forwarding ports
- Virtual Machine box linux distribution
- Virtual Machine Memory configuration
- Virtual Machine CPU configuration
- Virtual Machine Default NIC type
- Virtual Machine shared folders
- Vagrant provisioner Shell & Ansible