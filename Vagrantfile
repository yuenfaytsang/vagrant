# ########################################################################
# Author: Steven Yuen Fay Tsang
# License: GPLv3
# ########################################################################
#
# Add library reference to Vagrantfile
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |lib| require lib }

utils = VagrantUtils.new('config/config.yml')

utils.plugin
ProvUtils.provisioner(utils.cfg)

Vagrant.configure('2') do |vagrant|
  vagrant.ssh.insert_key = false

  utils.hostmanager(vagrant)

  utils.range.each do |i|
    vagrant.vm.define utils.vm_name(i) do |df|
      params = { obj: df, index: i }
      define = %w[box hostname private_ip fwd_port sync hosts_hotfix]

      define.each do |opt|
        utils.send(opt, params)
      end

      ProvUtils.action(obj: df, index: i, cfg: utils.cfg, ip: utils.ip(i))

      df.vm.provider 'virtualbox' do |vb|
        params = { obj: vb, index: i, cfg: utils.cfg }
        define = %w[cpus nic memory name gui]

        define.each do |provider|
          VbMod.send(provider, params)
        end
      end
    end
  end
end
