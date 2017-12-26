# Task-2: Expose and Scale Lets-Chat-Web
1. Create a Service to Lets-Chat-Web microservice using **kubectl expose deploy** command
  > * You can get the command options using ` kubectl expose --help ` or use bellow [kubectl Cheat Sheet](#kubectl-cheat-sheet)
  > * Get the Service Cluster-IP using `kubectl get svc` command. Then access one of the nodes in the cluster using `kube-ssh kube-node-1`, and there curl service-cluster-ip:service-port.
2. Change the Service type from ClusterIP to NodePort to make it accessible from outside the cluster.
  > * Use `kubectl edit svc my-service-name` to update the service specification with **type: NodePort**
  > * Get the Service Node port using `kubectl get svc` command. Then open the browser and acceess Lets-Chat-Web UI using kube-node-1:node-port.  Make sure you can access the UI also from the other 2 nodes.
3. Scale the Lets-Chat-Web pods to 4 instances using  **kubectl scale** command
  > * Explore the pods, using `kubectl get po -o wide`, to see which Nodes the new pods were scheduled to.
  > * Open the browser and acceess Lets-Chat-Web UI using each node in the cluster and see which pod responds.
4. Scale down the Lets-Chat-Web pods to 2 instances. Now they are running on 2 nodes - but you should be able to get response from every node. The node that is not running the pod will pass it to a pod from the other nodes.

### kubectl Cheat Sheet
  ```bash
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

# Delete a service
kubectl delete svc my-svc-name

```
