# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu1804"
  config.vm.box_check_update = false
  # config.vm.network "private_network", ip: "192.168.10.50"
  config.vm.network "forwarded_port", guest: 8888, host: 8888

  # we do not want a synced folder other than the default.
  # we will be extracting the tarred up fuzzingbook to home.
  config.vm.synced_folder "./fuzzingbook", "/vagrant/fuzzingbook"

  config.vm.provider "virtualbox" do |v|
    v.memory = 16384 # dont even attempt it if you do not have enough memory.
    v.cpus = 2
  end

  # apt-get -y install openjdk-11-jre-headless make docker.io graphviz python3-venv python3-pip libjson-c-dev
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get -y install make graphviz python3.6 python3-venv python3-pip cmake pkg-config python3-software-properties python3-apt jq graphicsmagick-imagemagick-compat firefox
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 2
    update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2
    pip3 install wheel
    pip3 install git+https://github.com/matplotlib/matplotlib#egg=matplotlib
    pip3 install git+https://github.com/uds-se/pyan#egg=pyan
    pip3 install ipypublish==0.6.7
    pip3 install showast enforce autopep8 mypy notedown requests z3-solver
    pip3 install git+https://github.com/MozillaSecurity/FuzzManager

    pip3 install numpy
    pip3 install scipy
    pip3 install pandas
    pip3 install svglib
    pip3 install selenium
    pip3 install networkx
    pip3 install pydot
    pip3 install graphviz
    pip3 install pudb
    pip3 install astor
    pip3 install jupyter

    pip3 install jupyter_contrib_nbextensions
    pip3 install jupyter_nbextensions_configurator
    jupyter contrib nbextension install --sys-prefix
    jupyter nbextension enable toc2/main --sys-prefix

    echo cd /home/vagrant/fuzzingbook >  /home/vagrant/startjupyter.sh
    echo jupyter notebook --ip 0.0.0.0 --port 8888 >> /home/vagrant/startjupyter.sh
    chmod +x /home/vagrant/startjupyter.sh

    echo rsync -az /vagrant/fuzzingbook/fuzzingbook/ /home/vagrant/fuzzingbook/ >  /home/vagrant/sync_to_home.sh
    chmod +x /home/vagrant/sync_to_home.sh

    echo rsync -az /home/vagrant/fuzzingbook/ /vagrant/fuzzingbook/fuzzingbook/ >  /home/vagrant/sync_from_home.sh
    chmod +x /home/vagrant/sync_from_home.sh

    wget https://github.com/mozilla/geckodriver/releases/download/v0.26.0/geckodriver-v0.26.0-linux64.tar.gz
    /bin/zcat geckodriver-v0.26.0-linux64.tar.gz | tar -xpf -
    mv geckodriver /usr/local/bin/

  SHELL
end
