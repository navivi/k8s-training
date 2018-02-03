# Install Dind Kubernetes Cluster
## 1. Pre Install

### 1.1 On Mac only: Ensure to have md5sha1sum installed

If not existing can be installed via brew install md5sha1sum.

### 1.2 Install Docker
#### 1.2.1 On Ubuntu
```bash
sudo apt-get update
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker $USER
```
#### 1.2.2 On Mac
Follow instructions to [install Docker for Mac](https://docs.docker.com/docker-for-mac/install/)

### 1.3 Install kubectl
#### 1.3.1 On Ubuntu
```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "source <(kubectl completion bash)" >> ~/.bashrc
```
#### 1.3.2 On Mac
```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/darwin/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

### 1.4 Install helm
```bash
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

```

## 2. Install 
```bash
wget https://navivi.github.io/k8s-training/installations/dind-cluster-v1.8.sh
chmod +x dind-cluster-v1.8.sh

./dind-cluster-v1.8.sh up
```
## 3. [OPTIONAL] Post Install
### 3.1 Create kube-ssh script
```bash
cat > kube-ssh <<EOF
#!/bin/bash
case "$1" in
  kube-master|10.192.0.2)
    docker exec -it kube-master bash
    ;;
  kube-node-1|10.192.0.3)
    docker exec -it kube-node-1 bash
    ;;
  kube-node-2|10.192.0.4)
    docker exec -it kube-node-2 bash
    ;;
  kube-node-3|10.192.0.5)
    docker exec -it kube-node-3 bash
    ;;
esac
EOF

chmod +x kube-ssh
sudo mv ./kube-ssh /usr/local/bin/kube-ssh
```

### 3.2 Edit /etc/hosts
#### 3.2.1 On Ubuntu
```bash
sudo echo "10.192.0.2   kube-master" >> /etc/hosts
sudo echo "10.192.0.3   kube-node-1" >> /etc/hosts
sudo echo "10.192.0.4   kube-node-2" >> /etc/hosts
sudo echo "10.192.0.5   kube-node-3" >> /etc/hosts
sudo echo "10.192.0.3   my-k8s.att.io" >> /etc/hosts
```
#### 3.2.2 On Mac
add 'my-k8s.att.io' to localhost in /etc/hosts

### 3.3 Install NFS server on host
#### 3.3.1 On Ubuntu
```bash
sudo apt install -y nfs-kernel-server
sudo mkdir -p /lets-chat-uploads
sudo sh -c 'echo "/lets-chat-uploads    *(rw,sync,no_root_squash)" >>/etc/exports'
sudo systemctl start nfs-kernel-server.service
```

