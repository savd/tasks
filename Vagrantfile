#TODO: Box - find out why udev takes so much time to load
#FIXED: puppetd binary to use puppet master? => fix /Applications/Vagrant/embedded/gems/gems/vagrant-1.0.4/lib/vagrant/provisioners/puppet_server.rb

Vagrant::Config.run do |config|

	boxes = {
		:pm => '2',
		:web => '3',
	}

    config.vm.guest = :suse
    config.vm.box = "opensuse"
	
    config.vm.provision :puppet, :module_path => 'bootstrap/puppet/modules' do |puppet|
        puppet.manifests_path = "bootstrap/puppet/manifests"
        puppet.manifest_file  = "init.pp"
    end

	boxes.each_pair do |box, last_octet|
		config.vm.define box do |c|
			c.vm.host_name = "#{box.to_s}.dev"
			c.vm.network :hostonly, "192.168.64.#{last_octet}"
			File.open("#{box.to_s}/.vagrant_map").readlines.each do |line|
				if line =~ /^gid (\d+)/ then
					c.nfs.map_uid = $1
					next
				elsif line =~ /^uid (\d+)/ then
					c.nfs.map_gid = $1
					next
				end
				mount, share = line.split(' ')
				c.vm.share_folder "#{box}-#{mount.strip.sub /\//,'-'}", "/#{mount}", "#{box}/#{share}", :nfs => true
			end if File.exist? "#{box.to_s}/.vagrant_map"
		end
	end
end
