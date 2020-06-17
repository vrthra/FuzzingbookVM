python=python3

clean: ; rm -rf *.log
clobber: clean;
	-$(MAKE) box-remove
	-rm -rf artifact artifact.tar.gz
	-rm -rf .db
results:; mkdir -p results

artifact.tar.gz: Vagrantfile Makefile
	rm -rf artifact && mkdir -p artifact/fuzzingbook
	cp README.md artifact/README.txt
	cp -r README.md Makefile Vagrantfile artifact/fuzzingbook
	cp -r Vagrantfile artifact/
	cd artifact/fuzzingbook/ && git clone https://github.com/uds-se/fuzzingbook.git
	tar -cf artifact1.tar artifact
	gzip artifact1.tar
	mv artifact1.tar.gz artifact.tar.gz

ARTIFACT=artifact.tar.gz

box-create: fuzzingbook.box
fuzzingbook.box: $(ARTIFACT)
	cd artifact && vagrant up
	cd artifact && vagrant ssh -c '~/sync_to_home.sh'
	cd artifact && vagrant ssh -c 'cd fuzzingbook && make sitemap'
	cd artifact && vagrant package --output ../fuzzingbook1.box --vagrantfile ../Vagrantfile.new
	mv fuzzingbook1.box fuzzingbook.box

box-hash:
	md5sum fuzzingbook.box

box-add: #| fuzzingbook.box
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
	VBoxManage startvm $(VM)  --type emergencystop
	VBoxManage unregistervm $(VM) -delete
