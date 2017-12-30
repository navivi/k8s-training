# Install Dind Kubernetes Cluster
## Pre Install

### On Mac only: Ensure to have md5sha1sum installed

If not existing can be installed via brew install md5sha1sum.

### Install Docker
#### On Ubuntu
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
#### On Mac
Follow instructions to [install Docker for Mac](https://docs.docker.com/docker-for-mac/install/)

### Install kubectl
#### On Ubuntu
```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "source <(kubectl completion bash)" >> ~/.bashrc
```
#### On Mac
```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/darwin/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

## Install 
```bash
wget https://cdn.rawgit.com/Mirantis/kubeadm-dind-cluster/master/fixed/dind-cluster-v1.8.sh
chmod +x dind-cluster-v1.8.sh

cat > kube-up.sh <<EOF
#!/bin/bash
export NUM_NODES=3
export CNI_PLUGIN=weave
./dind-cluster-v1.8.sh up
EOF

chmod +x ./kube-up.sh

./kube-up.sh
```
## Post Install
### Create kube-ssh script
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

### Edit /etc/hosts
```bash
sudo echo "10.192.0.2   kube-master" >> /etc/hosts
sudo echo "10.192.0.3   kube-node-1" >> /etc/hosts
sudo echo "10.192.0.4   kube-node-2" >> /etc/hosts
sudo echo "10.192.0.5   kube-node-3" >> /etc/hosts
sudo echo "10.192.0.3   my-k8s.att.io" >> /etc/hosts
```
### Install helm
```bash
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

helm init
```
### Install nginx-controller for Ingress
```bash
helm install stable/nginx-ingress --name my-nginx -f values.yaml
```
### [OPTIONAL] - Install NFS capabilities
#### On Ubuntu
##### NFS server on host
```bash
sudo apt install -y nfs-kernel-server
sudo mkdir -p /lets-chat-uploads
sudo sh -c 'echo "/lets-chat-uploads    *(rw,sync,no_root_squash)" >>/etc/exports'
sudo systemctl start nfs-kernel-server.service
```
##### NFS common on every node
```bash
docker exec -it kube-node-1 apt-get update && apt install -y nfs-common
docker exec -it kube-node-2 apt-get update && apt install -y nfs-common
docker exec -it kube-node-3 apt-get update && apt install -y nfs-common
```