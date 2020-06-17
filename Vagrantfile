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
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 2

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

    cat<<REQ > /tmp/fuzzmgr.req
amqp>=2.3.2,<2.4
appdirs>=1.4.3,<1.5
atomicwrites>=1.1.5,<1.3
attrs>=18.1.0,<19
backports.functools-lru-cache==1.5; python_version == '2.7'
billiard>=3.5.0.3,<3.6
boto>=2.48.0,<2.50
boto3==1.7.78
celery>=4.1.1,<4.3
certifi>=2018.4.16
chardet>=3.0.4,<3.1
configparser>=3.5.0,<3.6; python_version == '2.7'
coverage==4.5.2
Django>=1.11.20,<3
django-chartjs==1.3
djangorestframework>=3.9.4
enum34>=1.1.6,<1.2; python_version == '2.7'
fasteners>=0.14.1,<0.15
flake8>=3.7.9,<3.8
funcsigs>=1.0.2,<1.1; python_version == '2.7'
futures>=3.2.0,<3.3; python_version == '2.7'
idna>=2.6,<2.8
isort>=4.3.4,<4.4
kombu>=4.2.1,<4.3
laniakea>=1.17.0
lazy-object-proxy>=1.3.1,<1.4
mccabe>=0.6.1,<0.7
mock==2.0.0; python_version == '2.7'
monotonic==1.5
more-itertools>=4.2.0,<4.4
pluggy>=0.7.0,<0.8
py>=1.5.3
pycodestyle>=2.5,<2.6
pyflakes>=2.1.1,<2.2
pytest>=3.10.0,<4.0
pytest-cov>=2.6.0,<2.7
pytest-django>=3.4.4,<3.5
pytest-flake8>=1.0.1,<1.1
pytest-mock>=1.10.4,<1.11
pytest-pythonpath>=0.7.2,<0.8
python-dateutil>=2.8,<3
pytz>=2018.4
PyYAML>=5.1,<6.0
redis>=2.10.6,<2.11
requests>=2.20.1,<3
singledispatch>=3.4.0.3,<3.4.1; python_version == '2.7'
six>=1.12.0
# fuzzing-tc is only needed for the taskmanager module (requires python 3)
git+https://github.com/MozillaSecurity/fuzzing-tc#egg=fuzzing-tc
urllib3>=1.22,<2
vine>=1.1.4,<1.2
wrapt>=1.10.11,<1.11
markdown
REQ
  pip3 install -r /tmp/fuzzmgr.req

  SHELL
end
