# ########################################################################
# Author: Steven Yuen Fay Tsang
# License: GPLv3
# ########################################################################

require 'yaml'

# Helper functions for Vagrant
class VagrantUtils
  attr_reader :cfg_file
  attr_reader :cfg

  def initialize(cfg_file)
    @cfg_file = cfg_file
    @cfg = config
  end

  # Generate VM IP Range
  def range
    Range.new(0, @cfg['Project']['vm_number'] - 1)
  end

  # Generate client ip address
  def ip(index)
    ip = @cfg['Project']['vm_ip'].split('.')[0...-1]
    client_ip = @cfg['Project']['vm_ip'].split('.').pop.to_i + index

    ip << client_ip
    ip.join('.')
  end

  # Set base box for VM
  def define_box(num)
    box = @cfg['Default']['default_box']

    case @cfg["vm-#{num}"]['box']
    when nil
      box
    else
      @cfg["vm-#{num}"]['box']
    end
  rescue NoMethodError
    box
  end

  def box(params = {})
    obj = params[:obj]
    num = params[:index]

    obj.vm.box = define_box(num)
  end

  # Define forwarded ports
  def fwd_port(params = {})
    obj = params[:obj]
    num = params[:index]
    ssh = obj.vm.network 'forwarded_port', guest: 22, host: port(num), id: 'ssh'

    case @cfg["vm-#{num}"].key? 'fwd_port'
    when true
      @cfg["vm-#{num}"]['fwd_port'].each do |h|
        obj.vm.network 'forwarded_port', guest: h['guest'], host: h['host']
      end
      ssh
    end
  rescue NoMethodError
    ssh
  end

  # Define synced folders between host and guest
  def sync(params = {})
    obj = params[:obj]
    num = params[:index]
    vagrant = obj.vm.synced_folder '.', '/vagrant', disabled: true

    case @cfg["vm-#{num}"].key? 'sync'
    when true
      @cfg["vm-#{num}"]['sync'].each do |s|
        obj.vm.synced_folder s['host'], s['guest']
      end
      vagrant
    end
  rescue NoMethodError
    vagrant
  end

  def private_ip(params = {})
    obj = params[:obj]
    num = params[:index]

    obj.vm.network 'private_network', ip: ip(num)
  end

  # Remove /etc/hosts line where the vm name points to localhost for each
  # vm after it has been started
  def hosts_hotfix(params = {})
    obj = params[:obj]

    obj.trigger.after :up do |trigger|
      trigger.info = 'Fixing /etc/hosts localhost entry'
      trigger.run_remote = { inline: "sed -i '/^127.0.*'$(hostname)'/d' "\
                                     '/etc/hosts' }
    end
  end

  # Load config yaml file
  def config
    YAML.load_file @cfg_file
  end

  def vm_name(num)
    "#{@cfg['Project']['vm_name']}-#{num}"
  end

  def hostname(params = {})
    obj = params[:obj]
    num = params[:index]

    obj.vm.hostname = vm_name(num)
  end

  def name(obj, num)
    obj.name = vm_name(num)
  end

  def hostmanager(obj)
    obj.hostmanager.enabled = true
    obj.hostmanager.manage_guest = true
  end

  # Generate ssh forwarded port
  def port(num)
    @cfg['Project']['vm_ssh_fwd'] + num
  end

  # Install vagrant dependencies
  def plugin
    return false if Vagrant.has_plugin? 'vagrant-hostmanager'

    system 'vagrant plugin install vagrant-hostmanager'
    hostmanager_message
  end

  # Display info message when vagrant fails after installing vagrant-hostmanager
  # plugin via vagrant
  def hostmanager_message
    text = "\n\nIMPORTANT:\n\n"\
           "If vagrant-hostmanager plugin is installed via \"vagrant up\",\n"\
           "ignore the following hostmanager Error:\n\n"\
           "--- Unknown configuration section 'hostmanager' ---\n\n"\
           "No need to worry, just execute \"vagrant up\" again\n\n"

    puts "\e[1;93m#{text}\e[0m" unless Vagrant.has_plugin? 'vagrant-hostmanager'
  end
end
