Using virtual machines is a useful tool in CS research where you want to be able to reproduce a standard operating environment to develop and run code for an experiment or a test server.   You can use the same technology to create a virtual machine on your own computer and in the 'cloud' on a service like Amazon EC2 or the Nectar Research Cloud.  Getting the configuration of a VM right and making it repeatable is tricky but Vagrant simplifies that.  I'll give an example here of building a VM to run the second assignment.

http://www.vagrantup.com/

Vagrant is a tool for coordinating the creation and management of virtual machines. It is written so that it will work with different VM images running on different back-ends. So you can use it for local VMs running under VMWare (commercial) or VirtualBox (open source) and then use the same configuration to deploy a VM to a remote VMWare server or the Nectar Research Cloud.  

The first step in setting up this project is to gather the required materials. I've downloaded the source to sum-light and the provided data files from learn and put them into my project folder. I've also installed Vagrant and VirtualBox following their instructions:

http://docs.vagrantup.com/v2/installation/index.html
https://www.virtualbox.org/wiki/Downloads

(VirtualBox provides the virtual machine sub-system that will actually run the VMs that we create. Vagrant is a way to configure and manage virtual machines.)

The next step is to initialise a virtual machine following the instructions in the Vagrant documentation:

http://docs.vagrantup.com/v2/getting-started/index.html

In this example we'll create a virtual machine running the most recent version of the Ubuntu Linux operating system.  It is possible 

$ vagrant init precise32 http://files.vagrantup.com/precise32.box

Which gives me the message: 

A `Vagrantfile` has been placed in this directory. You are now
ready to `vagrant up` your first virtual environment! Please read
the comments in the Vagrantfile as well as documentation on
`vagrantup.com` for more information on using Vagrant.

I can now start the process:

$ vagrant up

this will use the information in the generated Vagrantfile to download the virtual machine image (precise32.box) and start it up. It will only be downloaded once so only the first invocation of this on any computer will be slow.   Here's the output of that command:

	Bringing machine 'default' up with 'virtualbox' provider...
	[default] Box 'precise32' was not found. Fetching box from specified URL for
	the provider 'virtualbox'. Note that if the URL does not have
	a box for this provider, you should interrupt Vagrant now and add
	the box yourself. Otherwise Vagrant will attempt to download the
	full box prior to discovering this error.
	Downloading or copying the box...
	Extracting box...te: 902k/s, Estimated time remaining: 0:00:02))
	Successfully added box 'precise32' with provider 'virtualbox'!
	[default] Importing base box 'precise32'...
	[default] Matching MAC address for NAT networking...
	[default] Setting the name of the VM...
	[default] Clearing any previously set forwarded ports...
	[default] Creating shared folders metadata...
	[default] Clearing any previously set network interfaces...
	[default] Preparing network interfaces based on configuration...
	[default] Forwarding ports...
	[default] -- 22 => 2222 (adapter 1)
	[default] Booting VM...
	[default] Waiting for VM to boot. This can take a few minutes.
	[default] VM booted and ready for use!
	[default] Mounting shared folders...
	[default] -- /vagrant


At this point, a virtual machine is running on my computer, it's set up for networking and my current directory has been shared with the virtual machine.   I can login to the VM with the 'vagrant ssh' command:

	$ vagrant ssh
	Welcome to Ubuntu 12.04 LTS (GNU/Linux 3.2.0-23-generic-pae i686)
	
	
	 * Documentation:  https://help.ubuntu.com/
	Welcome to your Vagrant-built virtual machine.
	Last login: Fri Sep 14 06:22:31 2012 from 10.0.2.2
	vagrant@precise32:~$ ls /vagrant/
	data-devtest.zip  data-held-out-test.zip  data-train.zip  most-freq-words.txt  svm_light.tar.gz  Vagrantfile

I've listed the contents of the /vagrant/ directory on the VM to see the files in my working directory (on my Mac) - the downloaded source code and data files and the Vagrantfile created above.  You can logout of the VM by typing 'logout' or Ctrl-D.  The VM is still running in the background, if you want to stop it, use the 'vagrant suspend' command:

	$ vagrant suspend
	[default] Saving VM state and suspending execution...

When you next run 'vagrant up' it will go much faster as it doesn't need to download the VM image.

At this point I have a working VM and I'm ready to start configuring it for my project. I'm going to stop here and check in all of the working files to a new Mercurial project.   All files will go into version control so I can keep track of my changes and share them with you. 

The next step is to set up the required software on the VM so that I can run my machine learning experiments.  This is called provisioning in Vagrant and is done by a shell script called bootstrap.sh.   

http://docs.vagrantup.com/v2/getting-started/provisioning.html

In our case, we need install the SVM-Light code and unpack the data files before we can get started. To unzip the data files we need to install the unzip package which doesn't come with the base operating system.  Here's the bootstrap.sh script that I wrote to achieve this:

	#!/usr/bin/env bash
	
	
	apt-get update
	apt-get install -y unzip
	
	
	# download the svm_light package and unpack
	mkdir svmlight
	cd svmlight
	wget -q http://download.joachims.org/svm_light/current/svm_light_linux32.tar.gz
	tar xzf svm_light_linux32.tar.gz
	cd ..
	
	
	# unpack the data files
	unzip /vagrant/data-devtest.zip
	unzip /vagrant/data-train.zip

I also need to add a line in the Vagrantfile to say where the bootstrap file is:

	# provisioning script
	config.vm.provision :shell, :path => "bootstrap.sh"

Now the VM is set up ready to run my python code to process the data.  I can integrate my python code with this project and in the VM it will be found in the /vagrant/ directory so could be run from there.   I've include a sample 'hello.py' in the python folder in my project.

To run my code I can now login to the VM (vagrant ssh) and run my python code to run my experiments.   Any output going to /vagrant/ will appear on my own computer so won't be lost when the VM is shut down.  The main advantage of this approach is that it provides a well-known software environment that is immune to changes in my own computer. If I get a new laptop, I can still run the same Vagrant commands to create my working environment with the right software in place.  For some projects this is all you need, but for others you want to move to using cloud based virtual machines. 

Moving to the Cloud
-------------------

Vagrant uses a series of provider plugins to implement the actual VM part of the service.  The default provider uses VirtualBox to make virtual machines but there are others for VMWare, Amazon Web Services and OpenStack (which is used on the Nectar Research Cloud).


	install plugin https://github.com/aodn/vagrant-openstack 
	
	on Nectar dashboard
	  Access & Security > API Access  -- download OpenStack RC File
	      this file contains settings need to connect to the OpenStack API
	
	 Settings (Top right) >> Reset Password
	      click on Reset Password blue button to generate an API key, copy and paste this key somewhere safe

Copy the Vagrantfile stanza from vagrant-openstack and fill out values from openrc.sh file downloaded above, os.username, os.api_key (password from above), os.endpoint, os.tenant.   Fill out desired image size and the source VM image with reference to the Nectar dashboard.  My config is:

	  config.vm.provider :openstack do |os|    # e.g.
	    os.username = "steve.cassidy@mq.edu.au"          # "#{ENV['OS_USERNAME']}"
	    os.api_key  = "xxxxxxxxxxxxxxxxxxxxxx"            # "#{ENV['OS_PASSWORD']}"
	    os.flavor   = /m1.medium/
	    os.image    = /NeCTAR Ubuntu 12.04.2/
	    os.endpoint = "https://keystone.rc.nectar.org.au:5000/v2.0/tokens"      # "#{ENV['OS_AUTH_URL']}/tokens"
	    os.keypair_name = "stevecassidy"
	    os.ssh_username = "ubuntu"
	
	
	    os.security_groups = ['ssh', 'http']
	    os.tenant = "pt-627"
	
	
	  end


I can now run 'vagrant up --provider=openstack' to start a VM on the Nectar Research Cloud:

	Ventoux > vagrant up --provider=openstack
	Bringing machine 'default' up with 'openstack' provider...
	WARNING: Nokogiri was built against LibXML version 2.8.0, but has dynamically loaded 2.9.0
	[default] Warning! The OpenStack provider doesn't support any of the Vagrant
	high-level network configurations (`config.vm.network`). They
	will be silently ignored.
	[default] Finding flavor for server...
	[default] Finding image for server...
	[default] Launching a server with the following settings...
	[default]  -- Flavor: m1.medium
	[default]  -- Image: NeCTAR Ubuntu 12.04.2 (Precise) amd64 UEC
	[default]  -- Name: default
	[default]  -- Security Groups: ["ssh", "http"]
	[default] Waiting for the server to be built...
	[default] Waiting for SSH to become available...
	[default] The server is ready!
	[default] Rsyncing folder: /Users/steve/Workspace/comp777a2vagrant/ => /vagrant
	[default] Running provisioner: shell...
	[default] Running: /var/folders/1h/ff403_v16bbdbf737kqf4qnr0000gp/T/vagrant-shell20131022-48311-lsboxc
	sudo: unable to resolve host default
	stdin: is not a tty
	Hit http://melbourne-np.clouds.archive.ubuntu.com precise Release.gpg
	Get:1 http://security.ubuntu.com precise-security Release.gpg [198 B]
	
	… (running the bootstrap.sh script)

I can now run 'vagrant ssh' to connect to the VM, I can also verify via the web control panel that there's a new VM running on my account.  








