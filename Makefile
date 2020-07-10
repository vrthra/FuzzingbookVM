python=python3

clean: ; rm -rf *.log
clobber: clean;
	-$(MAKE) box-remove
	-rm -rf artifact artifact.tar.gz
	-rm -rf .db
results:; mkdir -p results

fuzzingbook/.gitignore:
	git clone https://github.com/uds-se/fuzzingbook.git

artifact.tar.gz: Vagrantfile fuzzingbook/.gitignore
	rm -rf artifact && mkdir -p artifact/fuzzingbook
	cp README.md artifact/README.txt
	cp -r README.md Makefile Vagrantfile etc/pstree.py artifact/fuzzingbook
	cp -r Vagrantfile artifact/
	cp -r fuzzingbook artifact/fuzzingbook/
	tar -cf artifact1.tar artifact
	gzip artifact1.tar
	mv artifact1.tar.gz artifact.tar.gz

ARTIFACT=artifact.tar.gz

box-create: fuzzingbook.box
fuzzingbook.box: $(ARTIFACT)
	cd artifact && vagrant up
	cd artifact && vagrant ssh -c 'mkdir -p .jupyter/custom'
	cd artifact && vagrant ssh -c 'curl -sS -o .jupyter/custom/custom.css --location https://raw.githubusercontent.com/uds-se/fuzzingbook/master/docs/beta/notebooks/custom.css'
	cd artifact && vagrant ssh -c 'curl -sS -o fuzzmanager.tar.gz --location https://github.com/MozillaSecurity/FuzzManager/archive/0.3.2.tar.gz'
	cd artifact && vagrant ssh -c 'tar -xzf fuzzmanager.tar.gz'
	cd artifact && vagrant ssh -c 'mv FuzzManager-0.3.2 FuzzManager'
	cd artifact && vagrant ssh -c 'python3 FuzzManager/server/manage.py migrate'
	cd artifact && vagrant ssh -c 'python3 FuzzManager/server/manage.py createsuperuser --username demo --email demo@example.com --no-input'
	cd artifact && vagrant ssh -c 'python3 FuzzManager/server/manage.py shell -c "from django.contrib.auth.models import User; user = User.objects.get(username=\"demo\"); user.set_password(\"demo\"); user.save();"'
	cd artifact && vagrant ssh -c 'echo -ne "[Main]\nsigdir = /home/vagrant/signatures/\ntool = fuzzingbook\nserverport = 8000\nserverproto = http\nserverhost = 127.0.0.1\nserverauthtoken = " > .fuzzmanagerconf'
	cd artifact && vagrant ssh -c 'python3 FuzzManager/server/manage.py get_auth_token demo >> .fuzzmanagerconf'
	cd artifact && vagrant ssh -c 'mkdir -p signatures/'
	cd artifact && vagrant ssh -c 'curl -sS -o settings.py.patch --location https://raw.githubusercontent.com/uds-se/fuzzingbook/master/deploy/fuzzingbook-base/settings.py.patch'
	cd artifact && vagrant ssh -c 'cat settings.py.patch | (cd FuzzManager && patch -p1 )'
	cd artifact && vagrant ssh -c 'curl -sS -o jupyter_notebook_config.py --location https://raw.githubusercontent.com/uds-se/fuzzingbook/master/deploy/fuzzingbook-base/jupyter_notebook_config.py'
	cd artifact && vagrant ssh -c 'cat jupyter_notebook_config.py | sed -e "s/#c.NotebookApp.ip = .localhost./c.NotebookApp.ip = \"0.0.0.0\"/g" -e "s/^c.NotebookApp.default_url.*/c.NotebookApp.default_url = \"/notebooks/notebooks/00_Table_of_Contents.ipynb\""
> /home/vagrant/.jupyter/jupyter_notebook_config.py'
	cd artifact && vagrant ssh -c '~/sync_to_home.sh'
	cd artifact && vagrant ssh -c 'cd fuzzingbook && (cat /vagrant/fuzzingbook/patch.patch | patch -p1; echo)'
	cd artifact && vagrant ssh -c 'rm -rf fuzzmanager.tar.gz  grcov-linux-x86_64.tar.bz2  jupyter_notebook_config.py  settings.py.patch  sync_from_home.sh  sync_to_home.sh'
	cd artifact && vagrant package --output ../fuzzingbook1.box --vagrantfile ../Vagrantfile.new
	mv fuzzingbook1.box fuzzingbook.box

box-hash:
	md5sum fuzzingbook.box

box-add: fuzzingbook.box
	-vagrant destroy $$(vagrant global-status | grep fuzzingbook | sed -e 's# .*##g')
	rm -rf vtest && mkdir -p vtest && cp fuzzingbook.box vtest
	cd vtest && vagrant box add fuzzingbook ./fuzzingbook.box
	cd vtest && vagrant init fuzzingbook
	cd vtest && vagrant up

box-status:
	vagrant global-status | grep fuzzingbook
	vagrant box list | grep fuzzingbook

box-remove:
	-vagrant destroy $$(vagrant global-status | grep --ignore-case fuzzingbook | sed -e 's# .*##g')
	vagrant box remove fuzzingbook

show-ports:
	 sudo netstat -ln --program | grep 8888

box-connect1:
	cd artifact; vagrant up; vagrant ssh
box-connect2:
	cd vtest; vagrant ssh

rsync:
	rsync -avz  --partial-dir=.rsync-partial --progress --rsh="ssh" fuzzingbook.box shuttle:/scratch/rahul/vm/

VM=

vm-list:
	VBoxManage list vms

vm-remove:
	-VBoxManage startvm $(VM)  --type emergencystop
	VBoxManage unregistervm $(VM) -delete
