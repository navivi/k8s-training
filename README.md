# Using Kubernetes Workshop
In this workshop, you'll learn: 
- The architecture, primary components, and building blocks of Kubernetes
- How to set up and access a Kubernetes cluster in AKS using kubectl
- Ways to deploy and configure applications on Kubernetes

[Power Point Presentation](https://github.com/navivi/k8s-training/raw/adapt_to_aks/day-1/Using%20Kubernetes%20Day%201.pptx)


## Learning K8s with Lets-Chat
In this workshop we will deploy and scale, on kubernetes cluster, the application: <img width="90" alt="Image" src="https://github.com/user-attachments/assets/54d801b9-6293-4d8e-bea6-3bd70fd46543" />   
Let's Chat is a persistent messaging application that runs on Node.js and MongoDB with Nginx at the front.

![Let's Chat](http://i.imgur.com/0a3l5VF.png)

![Screenshot](http://i.imgur.com/C4uMD67.png)

### Let's Chat Architecture
![image](https://user-images.githubusercontent.com/34754379/118403211-0e76e080-b676-11eb-88ab-1fa453f8cee8.png)


### Tasks
1.  [Deploy and Explore Lets-Chat-Web](day-1/task-1/README.md)
2.  [Expose and Scale Lets-Chat-Web](day-1/task-2/README.md)
3.  [Rolling-Update Lets-Chat-Web](day-2/task-3/README.md)
4.  [Discover all Lets-Chat microservices](day-2/task-4/README.md)
5.  [Set Health-Checks and Self-Healing to Containers](day-3/task-5/README.md)
6.  [Get ENV Values from ConfigMap and Secrets](day-3/task-6/README.md)
7.  [Inject Files to Containers Using **configMap** and **secret** Volumes](day-4/task-7/README.md)
8.  [Share Directory Between 2 Containers in a Pod Using **emptyDir** Volume.](day-4/task-8/README.md)
9.  [Persist Lets-Chat-DB into the Node File-System Using **hostPath** Volume](day-5/task-9/README.md)
10. [Persist Lets-Chat-APP into External Shared File-System Using **persistentVolumeClaim** Volume](day-5/task-10/README.md)
11. [Expose Lets-Chat on FQDN:80 Using Ingress and Nginx-Controller](day-6/task-11/README.md)
12. [Write Helm Chart for Lets-Chat-Web](day-6/task-12/README.md)
13. [Use Lets-Chat chart-of-charts To Install/Upgrade](day-6/task-13/README.md)


# Installations
## - Using AKS

### Prerequisites

1. [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
2. [Install kubectl](https://learn.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-install-cli)
   
### Set cluster context

Open terminal and run the following commands

1. Login to your azure account
```bash
az login
```

2. Set the cluster subscription
```bash
az account set --subscription 9a4785ad-48b3-4c1a-b1e1-af8a924cd45d
```

3. Download cluster credentials
```bash
az aks get-credentials --resource-group nesiarg --name k8s-workshop --overwrite-existing
```

4. Create your K8s namespace​

Once you have run the command above to connect to the cluster, you can create your own namespace you will use in the workshop
Create and set namespace - use your own alias​

```bash
kubectl create namespace nesiavivi
```
```bash
kubectl config set-context k8s-workshop --namespace nesiaavivi
```

## - Using Kind

### Prerequisites
1. [Install Docker](https://docs.docker.com/get-docker/)
2. [Install Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
3. [Install Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

Create the following file **kind.yaml**
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
  - role: worker
```

Open the terminal and run:
```
kind create cluster --config kind.yaml
```

It may take few minutes to create the kubernetes cluster...

<img width="690" alt="Image" src="https://github.com/user-attachments/assets/9752853d-2f76-46ba-b86b-7ab99e26748c" />

