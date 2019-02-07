# ########################################################################
# Author: Steven Yuen Fay Tsang
# License: GPLv3
# ########################################################################

# Include all ruby libraries from the lib directory
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |lib| require lib }

# Load configuration YAML file
utils = VagrantUtils.new('config/config.yml')

# Install vagrant-hostmanager plugin if not present
utils.plugin

# Read Provisioner settings from config
ProvUtils.provisioner(utils.cfg)

# Main Vagrant project setup
Vagrant.configure('2') do |vagrant|
  vagrant.ssh.insert_key = false

  # Setup VM's defined in config.yml
  utils.range.each do |i|
    vagrant.vm.define utils.vm_name(i) do |df|
      params = { obj: df, index: i }
      define = %w[box hostname private_ip fwd_port sync hosts_hotfix]

      define.each do |opt|
        utils.send(opt, params)
      end

      # Setup Provisioner
      ProvUtils.action(obj: df, index: i, cfg: utils.cfg, ip: utils.ip(i))

      # Modify VirtualBox Settings
      df.vm.provider 'virtualbox' do |vb|
        params = { obj: vb, index: i, cfg: utils.cfg }
        define = %w[cpus nic memory name gui hdd]

        define.each do |provider|
          VbMod.send(provider, params)
        end
      end
    end
  end
end
