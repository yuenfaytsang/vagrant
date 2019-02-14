# ########################################################################
# Author: Steven Yuen Fay Tsang
# License: GPLv3
# ########################################################################

# Helper functions to modifiy Virtualbox VM's
module VbMod
  # Set cpus for VM
  def self.cpus(params = {})
    obj = params[:obj]
    num = params [:index]
    config = params[:cfg]

    obj.cpus = VbMod.define_cpus(config, num)
  end

  # Set memory for VM
  def self.memory(params = {})
    obj = params[:obj]
    num = params [:index]
    config = params[:cfg]

    obj.memory = VbMod.define_memory(config, num)
  end

  # Define default nic type
  def self.nic(params = {})
    obj = params[:obj]
    config = params[:cfg]

    obj.default_nic_type = VbMod.define_nic(config)
  end

  # Define virtualbox vm name
  def self.name(params = {})
    obj = params[:obj]
    num = params [:index]
    config = params[:cfg]

    obj.name = VbMod.define_name(config, num)
  end

  # Define Virtualbox GUI mode for VM
  def self.gui(params = {})
    obj = params[:obj]

    obj.gui = false
  end

  # Gather CPU settings from config file
  def self.define_cpus(config, index)
    case config["vm-#{index}"]['cpus']
    when nil
      config['Default']['default_cpus']
    else
      config["vm-#{index}"]['cpus']
    end
  rescue NoMethodError
    config['Default']['default_cpus']
  end

  # Gather memory settings from config file
  def self.define_memory(config, index)
    case config["vm-#{index}"]['memory']
    when nil
      config['Default']['default_memory']
    else
      config["vm-#{index}"]['memory']
    end
  rescue NoMethodError
    config['Default']['default_memory']
  end

  # Gather NIC settings from config file
  def self.define_nic(config)
    config['Default']['default_nic']
  end

  # Gather VM name from config file
  def self.define_name(config, index)
    "#{config['Project']['vm_name']}-#{index}"
  end

  # Get the default Virtualbox VM directory path and create
  # the corresponding VM path based on the VM's name
  def self.hdd_dir(config, num)
    folder = IO.popen('VBoxManage list '\
                      'systemproperties')
    base = folder.readlines[38].delete("\s\n").split(':')[1]
    "#{base}/#{config['Project']['vm_name']}-#{num}"
  end

  # Add disks to a VM
  def self.add_hdd(params)
    obj = params[:obj]
    num = params[:index]
    config = params[:cfg]
    dir = VbMod.hdd_dir(config, num)

    config["vm-#{num}"]['hdd'].each_with_index do |size, i|
      hdd_name = "#{dir}/hdd-00#{i + 2}.vmdk"
      next if File.exist?(hdd_name)

      VbMod.vbox_storage_cmd(hdd_name, size, i, obj)
    end
  end

  # VBox commands to create & attach additional disks
  def self.vbox_storage_cmd(hdd_name, size, num, obj)
    obj.customize ['createhd', 'disk', '--filename', hdd_name,
                   '--size', size * 1024, '--format', 'VMDK',
                   '--variant', 'Fixed']
    obj.customize ['storageattach', :id, '--storagectl',
                   'SATA Controller', '--port', num + 1, '--device',
                   0, '--type', 'hdd', '--medium', hdd_name]
  end

  # Wrapper to configure additional disks. Referres to add_hdd
  def self.hdd(params)
    num = params[:index]
    config = params[:cfg]
    return false unless config.include? "vm-#{num}"
    return false unless config["vm-#{num}"].include? 'hdd'

    case config["vm-#{num}"]['hdd']
    when nil
      false
    else
      VbMod.add_hdd(params)
    end
  end
end
