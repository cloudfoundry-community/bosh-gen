# Vagrant used to allow non-Ubuntu hosts to execute
# apt-get commands to fetch debian packages.
Vagrant.configure('2') do |config|

  config.vm.hostname='boshrelease-builder'
  config.vm.box = "lucid64"
  config.vm.box_url = "http://files.vagrantup.com/lucid64.box"

  # Need NFS enabled, and hence a private network for virtualbox
  # as discussed in this project's patch
  # https://github.com/reidab/citizenry/commit/590ca245b9a4fc96c55ab7bc3bbafa38583f8cda
  config.vm.network "private_network", ip: "192.168.50.5"
  config.vm.synced_folder ".", "/vagrant", type: "nfs"
end
