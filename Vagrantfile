# -*- mode: ruby -*-
# vi: set ft=ruby :


require 'vagrant-openstack-plugin'


# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Every Vagrant virtual environment requires a box to build off of.
  #config.vm.box = "precise32" 
  config.vm.box = "dummy"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  #config.vm.box_url = "http://files.vagrantup.com/precise32.box"
  config.vm.box_url = "https://github.com/cloudbau/vagrant-openstack-plugin/raw/master/dummy.box"
  
  # provisioning script
  config.vm.provision :shell, :path => "bootstrap.sh"

  # Make sure the private key from the key pair is provided
  config.ssh.private_key_path = "~/.ssh/id_rsa"

  config.vm.provider :openstack do |os|    # e.g.
    os.username = "steve.cassidy@mq.edu.au"          # "#{ENV['OS_USERNAME']}"
    os.api_key  = "xxxxxxxxxxxxxxxxxxxx"             # "#{ENV['OS_PASSWORD']}" 
    os.flavor   = /m1.medium/
    os.image    = /NeCTAR Ubuntu 12.04.2/
    os.endpoint = "https://keystone.rc.nectar.org.au:5000/v2.0/tokens"      # "#{ENV['OS_AUTH_URL']}/tokens"  
    os.keypair_name = "stevecassidy"
    os.ssh_username = "ubuntu"

    os.security_groups = ['ssh', 'http']
    os.tenant = "pt-627"         

  end
end

