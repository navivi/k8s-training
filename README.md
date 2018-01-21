![Let's Chat](http://i.imgur.com/0a3l5VF.png)

![Screenshot](http://i.imgur.com/C4uMD67.png)
A self-hosted chat app for small teams
# K8s Training with Lets-Chat
In this training we will deploy and scale **let's chat** application on kubernetes cluster. Let's Chat is a persistent messaging application that runs on Node.js and MongoDB with Nginx at the front.

### Let's Chat Architecture
![Lets-Chat Architecture](images/lets-chat-arch.png)

### Tasks
1.  [Deploy and Explore Lets-Chat-Web](day-1/task-1/README.md)
2.  [Expose and Scale Lets-Chat-Web](day-1/task-2/README.md)
3.  [Rolling-Update Lets-Chat-Web](day-1/task-3/README.md)
4.  [Discover all Lets-Chat microservices](day-1/task-4/README.md)
5.  [Set Health-Checks and Self-Healing to Containers](day-2/task-5/README.md)
6.  [Get ENV Values from ConfigMap and Secrets](day-2/task-6/README.md)
7.  [Inject Files to Containers Using **configMap** and **secret** Volumes](day-2/task-7/README.md)
8.  [Share Directory Between 2 Containers in a Pod Using **emptyDir** Volume.](day-3/task-8/README.md)
9.  [Persist Lets-Chat-DB into the Node File-System Using **hostPath** Volume](day-3/task-9/README.md)
10. [Persist Lets-Chat-APP into External Shared File-System Using **persistentVolumeClaim** Volume](day-3/task-10/README.md)
11. [Dynamic Provisioning for Lets-Chat-APP and Lets-Chat-DB](day-3/task-11/README.md)
12. [Scale Lets-Chat-APP by Adding Redis microservice](day-4/task-13/README.md)
13. Scale Lets-Chat-DB Using StatefulSet Controller
14. Delete Old Upload-Files Periodicly Using CronJob Controller
15. [Expose Lets-Chat on FQDN:80 Using Ingress and Nginx-Controller](day-5/task-15/README.md)
16. [Write Helm Chart for Lets-Chat-Web](day-5/task-16/README.md)
17. [Use Lets-Chat chart-of-charts To Install/Upgrade](day-5/task-17/README.md)


### Installations
[Kubernetes Cluster for Training](installations/README.md)
