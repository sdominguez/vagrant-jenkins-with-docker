Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/bionic64"
  config.vm.hostname = "ciserver"

  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 50000, host: 50000
  config.vm.network "public_network"

  config.vm.synced_folder "workspace", "/var/workspace"


  config.vm.provider "virtualbox" do |vb|
    vb.name = "ciserver" 
  end

  config.vm.provision "shell", path: "dockerprovision.sh"
end