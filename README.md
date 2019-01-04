# Vagrant Project via config file 

## Goal of this Project
The goal of this small project, is to ease the use of vagrant, by making your vagrant Project configurable via a single configuration file, without caring about the vagrant/ruby syntax inside a Vagrantfile.

## Features
- Configure your Vagrant project via a configuration file
- Easy Multi VM environment setup by just declaring the amount of VM's needed
- Ansible provisioning & automatically generated ansible inventory
- Easy vagrant shell provisioning for each VM individually by creating a scripts directory sttructure


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
  
## Ansible Provisioner
When configuring the ansible provisioner, an ansible directory is beeing created inside
your Vagrant project directory. Within this ansible directory following directory and files are beeing created:  
  - ansible.cfg / ansible configuration file
  - inventory / directory containing your inventory files
  - roles / directory containing your ansible roles
  - group_vars / directory containing group variables for your inventory groups

By default there will be an inventory file created named `hosts` inside the `inventory` directory, based on your VM names and their corresponding private ip addresses. Each time you `vagrant up` your project, this inventory file is beeing recreated. To make changes to your inventory persistent across vagrant up's, you can place additional inventory files inside the inventory directory. These are beeing merged by ansible.

After placing your playbooks, roles, inventory files etc inside the ansible and corresponding directories, you can invoke ansible & ansible-playbook commands inside the ansible directory.

>Note:  
the Vagrant project currently expects the target VM's to have either python3 installed and available underneath /usr/bin/python3 or your python installation linked to /usr/bin/python3.
This behavior is beeing configured by the `ansible_python_interpreter directive` in the ansible/group_vars/all file inside your Vagrant project by default.

## Shell Provisioner
When configuring the shell provisioner, a sripts directory is beeing created inside
your Vagrant project directory. Within this scripts directory, each VM that has been configured, will have its own scripts directory based on the VM name.

You can place your shell provisioner scripts inside those directories and execute them via the `vagrant provision` command.

