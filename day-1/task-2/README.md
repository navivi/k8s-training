# Task-2: Deploy, Expose and Scale Lets-Chat-Web
1. Create a Deployment of Lets-Chat-Web microservice using **kubectl create deploy** command
  > * You can get the command options using ` kubectl create --help ` or use bellow [kubectl Cheat Sheet](#kubectl-cheat-sheet)
  > * The image name of Lets-Chat-Web is: `navivi/lets-chat-web:v1`
2. Create a Service to Lets-Chat-Web microservice using **kubectl expose deploy** command
  > * Try to access the service by running `curl` from the `my-app` pod. 
3. Change the Service type from ClusterIP to LoadBalancer to make it accessible from outside the cluster.
  > * Use `kubectl edit svc my-service-name` to update the service specification with **type: LoadBalancer**
  > * Get the Service External-IP using `kubectl get svc` command. Then open the browser and acceess Lets-Chat-Web UI using External-IP:service-port.  
4. Scale the Lets-Chat-Web pods to 4 instances using  **kubectl scale** command
  > * Explore the pods, using `kubectl get po -o wide`, to see which Nodes the new pods were scheduled to.
  > * Open the browser and acceess Lets-Chat-Web UI using each node in the cluster and see which pod responds.
5. Scale down the Lets-Chat-Web pods to 2 instances. Now they are running on 2 nodes - but you should be able to get response from every node. The node that is not running the pod will pass it to a pod from the other nodes.

### kubectl Cheat Sheet
  ```bash
# Create a deployment with single pod
kubectl create deploy my-app --image nginx

# List all deployments
kubectl get deploy

# Create a service for my-app deployment, on port 80 and connects to the containers on port 8000.
kubectl expose deployment my-app --port=80 --target-port=8000

# List all services
kubectl get svc

# Open vi editor to the service specification where you can update its state
kubectl edit svc my-svc-name

# List pods and show all labels as the last column
kubectl get po --show-labels

# Scale a deployment named 'foo' to 3.
kubectl scale deploy my-app --replicas=3

# Delete deployment and all its pods
kubectl delete deploy my-deployment-name

# Delete a service
kubectl delete svc my-svc-name

```
