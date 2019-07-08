# Task-3: Rolling-Update Lets-Chat-Web
1. Delete the previous Deployment, using  **kubectl delete deploy** command, of Lets-Chat-Web microservice and create new Deployment using **kubectl create -f web-deploy.yaml** command
  > * You can use bellow [Specifications Examples](#specifications-examples) to define the yaml files
  > * The Image name of Lets-Chat-Web:  **navivi/lets-chat-web:v1**
  > * The Web server is listening on port 80
  > * Disable the code feature by configuring the Lets-Chat-Web with environment variable name: **CODE_ENABLED** and value "false".
  > * Add a second label to the pods (in spec.template.labels of web-deploy.yaml) of **version:v1** 
2. Create a Service to Lets-Chat-Web microservice using **kubectl create -f web-svc.yaml** command
  > * The service type of this microservice should be NodePort
3. Verify the pods are ready and you are able to access Lets-Chat-Web UI via browser using node-port
  > * Get the Service Node port using `kubectl get svc` command. Then open the browser and acceess Lets-Chat-Web UI using kube-node-1:node-port.  Make sure you can access the UI also from the other 2 nodes.
  > * Check the logs of the pods - and see it runs v1 image
4. Update the deployment, using `kubectl apply -f web-deploy.yaml` command, and change the image to **navivi/lets-chat-web:v2** and also change the label to **version: v2** in spec.template.metadata.labels
  > * Explore the pods rolling update using `kubectl get po --show-labels`
  > * Verify the update using `kubectl logs new-pod-name`
5. Rollback to the previous deployment using `kubectl rollout undo deployment deploy-name`
  > * Explore the pods rollback using `kubectl get po --show-labels`
  > * Verify the update using `kubectl logs new-pod-name`

### Specifications Examples
#### nginx-svc.yaml
```yaml
kind: Service
apiVersion: v1
metadata:
  name: nginx  # The name of your service
spec:
  selector:
    app: nginx  # defines how the Service finds which Pods to target. Should match labels defined in the Pod template
  ports:
  - protocol: TCP
    port: 80 # The service port
    targetPort: 80 # The pods port
  type: NodePort # [OPTIONAL] If you want ClusterIP you can drop this line 
```
#### nginx-deploy.yaml
```yaml
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: nginx-deployment # The name of your deployment
spec:
  replicas: 1 # Number of replicated pods
  selector:
    matchLabels:
      app: nginx # defines how the Deployment finds which Pods to manage. Should match labels defined in the Pod template
  template:
    metadata:
      labels:
        app: nginx # The label of the pod
    spec:
      containers:
      - name: nginx # The container name
        image: nginx:1.7.9 # The DockerHub image
        ports:
        - containerPort: 80 # Open pod port 80 for the container
        env: # [OPTIONAL] add environments values 
        - name: SOME_ENV_NAME
          value: some-env-value
```
