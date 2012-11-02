#TODO:
# Box: chkconfig rpcbind on
# Box: disable vboxsf module load (/etc/init.d/vboxadd) - slows down startup? - NOPE, it's udev
# Box: remove Grub delay (/etc/default/grub && grub2-mkconfig -o /boot/grub2/grub.cfg)
# + Vagrant: puppetd binary to use puppet master? => fix /Applications/Vagrant/embedded/gems/gems/vagrant-1.0.4/lib/vagrant/provisioners/puppet_server.rb

Vagrant::Config.run do |config|

    config.vm.guest = :suse
    config.vm.box = "opensuse"

    config.vm.provision :puppet, :module_path => 'config/puppet/modules' do |puppet|
        puppet.manifests_path = "config/puppet/manifests"
        puppet.manifest_file  = "init.pp"
    end

	config.vm.define :web do |config|
        config.vm.host_name = "web.dev"
		#config.vm.boot_mode = :gui
		config.vm.network :hostonly, '192.168.64.2'
        config.vm.share_folder 'web-root', '/vagrant', '.', :nfs => true
	end

	config.vm.define :db do |config|
	    config.vm.host_name = "db.dev"
	    config.vm.network :hostonly, '192.168.64.3'
    end

    config.vm.define :pm do |cfg|
        cfg.vm.host_name = "pm.dev"
        cfg.vm.network :hostonly, '192.168.64.4'
        cfg.vm.share_folder 'pm-manifests', '/etc/puppet/manifests', 'config/puppet/pm', :nfs => true
        cfg.vm.share_folder 'pm-hiera', '/etc/puppet/hiera', 'config/puppet/hiera', :nfs => true
    end

end