# Setup VM with K8s Dind Cluster
## 1. Prerequisites (Make sure you have the right version)
Install | Windows | Mac | Linux (Debian-based) | 
--- | --- | --- | --- | 
git | Just go to http://git-scm.com/download/win and the download will start automatically. Note that this is a project called Git for Windows, which is separate from Git itself; for more information on it, go to https://git-for-windows.github.io/.| simply by trying to run git from the Terminal the very first time.
`git --version`
If you don’t have it installed already, it will prompt you to install it. | sudo apt-get install git-all |
VirtualBox (~5.1)| https://download.virtualbox.org/virtualbox/5.1.32/VirtualBox-5.1.32-120294-Win.exe | https://download.virtualbox.org/virtualbox/5.1.32/VirtualBox-5.1.32-120294-OSX.dmg | https://download.virtualbox.org/virtualbox/5.1.32/virtualbox-5.1_5.1.32-120294~Ubuntu~xenial_amd64.deb |
Vagrant (~2.0)| https://releases.hashicorp.com/vagrant/2.0.2/vagrant_2.0.2_x86_64.msi | https://releases.hashicorp.com/vagrant/2.0.2/vagrant_2.0.2_x86_64.dmg | https://releases.hashicorp.com/vagrant/2.0.2/vagrant_2.0.2_x86_64.deb |

### 2. Git clone k8s-training repository
In your host run:
`git clone https://github.com/navivi/k8s-training`

### 3. Vagrant Up
Inside the repository working-dir (cloned in previous step) run:
`vagrant up`

Make sure you get running VM in your VirtualBox with the name: "k8s_training"

### 4. Change the VM Network Adapter to Bridged
* Right-Click the VM in the VirtualBox and Click 'Settings'
* Choose the 'Network' Tab
* In the 'Attached to' combobox - Choose 'Bridged Adapter' and then click 'OK'

### 5. Login to VM Desktop
* Double Click the VM in the VirtualBox (or click 'Show')
* In the console - login with
  > username: k8s
  > password: Aa123456
* Now run: `desktop`
* You should see ubuntu-xenial GUI

### 6. Start K8s Cluster in VM
* In the VM desktop open terminal and run: `./dind-cluster-v1.8.sh up`
* Let it run for few minutes..
* Make sure you get green log: "Access dashboard at:" "http://k8s-training:..."
* Verify you get the k8s dashboard in the VM Browser

