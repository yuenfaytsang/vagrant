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
end
