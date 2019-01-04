# ########################################################################
# Author: Steven Yuen Fay Tsang
# License: GPLv3
# ########################################################################

# Helper functions to use ansible and shell as vagrant provisioner
module ProvUtils
  A_BASE = 'ansible'.freeze
  S_BASE = 'scripts'.freeze
  INVENTORY = "#{ProvUtils::A_BASE}/inventory".freeze
  ROLES = "#{ProvUtils::A_BASE}/roles".freeze
  GROUPVARS = "#{ProvUtils::A_BASE}/group_vars".freeze

  # Define Provisoning tasks
  def self.provisioner(cfg)
    return false unless cfg.include? 'Provisioner'

    case cfg['Provisioner']
    when 'shell'
      ProvUtils.structure(cfg)
    when 'ansible'
      ProvUtils.ansible
    end
  rescue NoMethodError
    puts 'No provisioner configured. Continuing ...'
  end

  # Define Provisioner action
  def self.action(params = {})
    obj = params[:obj]
    index = params[:index]
    ip = params[:ip]
    cfg = params[:cfg]

    return false unless cfg.include? 'Provisioner'

    case cfg['Provisioner']
    when 'shell'
      ProvUtils.execute_scripts(obj: obj, index: index, cfg: cfg)
    when 'ansible'
      ProvUtils.inventory(obj: obj, index: index, cfg: cfg, ip: ip)
    end
  rescue NoMethodError
    puts 'No provisioner configured. Continuing ...'
  end

  # ########################################################################
  # ANSIBLE
  # ########################################################################

  # Create Ansible configuration and directory structure
  def self.ansible
    ProvUtils.ansible_structure
    ProvUtils.ansible_python3
    ProvUtils.ansible_config
  end

  # Create Ansible directory structure
  def self.ansible_structure
    Dir.mkdir ProvUtils::A_BASE unless Dir.exist? ProvUtils::A_BASE
    dirs = [ProvUtils::INVENTORY, ProvUtils::ROLES, ProvUtils::GROUPVARS]

    dirs.each do |dir|
      Dir.mkdir dir unless Dir.exist? dir
    end
  end

  # Create group_vars all file to set ansible to python3
  def self.ansible_python3
    dir = ProvUtils::GROUPVARS

    File.open("#{dir}/all", 'w') do |f|
      f.write 'ansible_python_interpreter: /usr/bin/python3'
    end
  end

  # Create configuration files
  def self.ansible_config
    dir = ProvUtils::A_BASE
    keyfile = '~/.vagrant.d/insecure_private_key'

    File.open("#{dir}/ansible.cfg", 'w') do |f|
      f.write "[defaults]\ninventory = inventory\n"\
      "host_key_checking = False\n"\
      "roles_path = roles\nremote_user = vagrant\n"\
      "private_key_file = #{keyfile}\n\n[privilege_escalation]\n"\
      "become = True\nbecome_method = sudo\nbecome_user = root\n"\
      "become_ask_pass = False\n"
    end
  end

  # Create ansible directory structure within the Vagrant project & create
  # the ansible inventory file, based on the vagrant configuration
  def self.inventory(params = {})
    obj = params[:obj]
    index = params[:index]
    ip = params[:ip]
    cfg = params[:cfg]
    inv = "#{ProvUtils::INVENTORY}/hosts"

    if Dir.exist? ProvUtils::A_BASE
      obj.trigger.after :up do |trigger|
        trigger.name = 'Updating Ansible Inventory'
        trigger.ruby do |_|
          File.truncate(inv, 0) if index.zero? && File.exist?(inv)
          File.open(inv, 'a') do |f|
            f.write "[#{cfg['Project']['vm_name']}-#{index}]\n#{ip}\n\n"
          end
        end
      end
    end
  end

  # ########################################################################
  # SHELL
  # ########################################################################

  # Create shell provisioner scripting directories
  def self.structure(cfg)
    path = ProvUtils::S_BASE
    vm_index = cfg['Project']['vm_number'] - 1
    vm = cfg['Project']['vm_name']
    amount = Range.new(0, vm_index)

    Dir.mkdir(path) unless Dir.exist? path
    amount.each_with_index do |_, i|
      Dir.mkdir("#{path}/#{vm}-#{i}") unless Dir.exist? "#{path}/#{vm}-#{i}"
    end
  end

  # Execute every script file that has been placed in the VM's script directory
  def self.execute_scripts(params = {})
    obj = params[:obj]
    cfg = params[:cfg]
    index = params[:index]
    dir = "#{ProvUtils::S_BASE}/#{cfg['Project']['vm_name']}-#{index}"
    nd = ['.', '..']

    return false if
    Dir.entries("scripts/#{cfg['Project']['vm_name']}-#{index}").size <= 2

    Dir.entries(dir).reject do |f|
      unless nd.include? f
        obj.vm.provision :shell, name: "Exectuting scripts in #{dir}",
                                 path: "#{dir}/#{f}"
      end
    end
  end
end
