# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
	if Vagrant.has_plugin?("vagrant-cachier")
		config.cache.auto_detect = true
	end

	config.vm.provider :virtualbox do |vb|
		vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
		vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
		vb.customize ["modifyvm", :id, "--nictype3", "virtio"]
		vb.memory = 1024
		vb.cpus = 2
	end

  config.vm.define :master do |master|
		master.vm.hostname = "puppet.test"

		master.vm.box = "precise64"
		master.vm.box_url = "http://files.vagrantup.com/precise64.box"
	
		master.vm.network :private_network, ip: "192.168.251.210"
			
		master.vm.provision :shell, :path => "scripts/puppet_master.sh"
		master.vm.provision :shell, :path => "scripts/puppet_r10k.sh"

		master.vm.provision :puppet do |puppet|
			puppet.manifests_path = "VagrantConf/manifests"
			puppet.manifest_file  = "default.pp"
			puppet.options        = "--verbose --modulepath /home/vagrant/modules"
		end 

    master.vm.synced_folder "puppet/manifests", "/etc/puppet/manifests"
    master.vm.synced_folder "puppet/modules", "/etc/puppet/modules"
    master.vm.synced_folder "puppet/hieradata", "/etc/puppet/hieradata"
  end

	(0..2).each do |i|
		config.vm.define "mon#{i}" do |mon|
			mon.vm.hostname = "ceph-mon#{i}.test"
			mon.vm.network :private_network, ip: "192.168.251.1#{i}"
			mon.vm.network :private_network, ip: "192.168.252.1#{i}"
			mon.vm.provision :shell, :path => "scripts/mon.sh"
		end
	end

	 (0..2).each do |i|
		 config.vm.define "osd#{i}" do |osd|
			 osd.vm.hostname = "ceph-osd#{i}.test"
			 osd.vm.network :private_network, ip: "192.168.251.10#{i}"
			 osd.vm.network :private_network, ip: "192.168.252.10#{i}"
			 osd.vm.provision :shell, :path => "scripts/osd.sh"
			 (0..1).each do |d|
				 osd.vm.provider :virtualbox do |vb|
					 vb.customize [ "createhd", "--filename", "disk-#{i}-#{d}", "--size", "5000" ]
					 vb.customize [ "storageattach", :id, "--storagectl", "SATA Controller", "--port", 3+d, "--device", 0, "--type", "hdd", "--medium", "disk-#{i}-#{d}.vdi" ]
				 end
			 end
		 end
	 end

	 (0..1).each do |i|
		 config.vm.define "mds#{i}" do |mds|
			 mds.vm.hostname = "ceph-mds#{i}.test"
			 mds.vm.network :private_network, ip: "192.168.251.15#{i}"
			 mds.vm.provision :shell, :path => "scripts/mds.sh"
		 end
	 end
end
