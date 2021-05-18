# Using Kubernetes Training
In this course, you'll learn: 
- The origin, architecture, primary components, and building blocks of Kubernetes
- How to set up and access a Kubernetes cluster using Kind
- Ways to run applications on the deployed Kubernetes environment and access the deployed applications


## K8s Training with Lets-Chat
In this training we will deploy and scale **let's chat** application on kubernetes cluster. Let's Chat is a persistent messaging application that runs on Node.js and MongoDB with Nginx at the front.

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


### Installations

##### Requirements
* [Vagrant](https://www.vagrantup.com/downloads)
* [VirtualBox](https://www.virtualbox.org/)

Run

```
vagrant init navivi/k8s-training --box-version 1
vagrant up
```

Show the desktop VM from VirtualBox, 

Login Credentials are:

- Username: vagrant

- Password: vagrant

![image](https://user-images.githubusercontent.com/34754379/118403830-f81e5400-b678-11eb-949a-b2b3f03db72c.png)

Open the Terminal, by clicking the 'Show Applications' at the left bottom and search 'Terminal' 

![image](https://user-images.githubusercontent.com/34754379/118403954-90b4d400-b679-11eb-97ec-a53b8f7f33a8.png)

In the terminal, run:
```
./kube-ssh
kind create cluster --config kind.yaml
```

It may take few minutes to create the kubernetes cluster...

Once it is done, check the cluster is up and ready by runinng:
```
kubectl get nodes
```
![image](https://user-images.githubusercontent.com/34754379/118404499-d4a8d880-b67b-11eb-9cd1-30d012f42de0.png)
