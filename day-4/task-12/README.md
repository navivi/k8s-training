# Task-12: Scale Lets-Chat-APP by Adding Redis microservice

In this task we would like to scale Lets-Chat-App replicas. In order to scale - The App container should save the websocket sessions outside. We'll use Redis for that.

1. Create New microservice Lets-Chat-Cache. 
  > * Create **deployment** and **service**
  > * Redis image name is: `redis:latest`
  > * Redis port: **6379**
2. You should upgrade the Lets-Chat-App image tag to **v2**
3. Add the Lets-Chat-App the Redis Service Name and Port in Environment Variables called: **REDIS_HOST**, **REDIS_PORT**


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
    targetPort: 9376 # The pods port
  type: NodePort # [OPTIONAL] If you want ClusterIP you can drop this line 
```
#### nginx-deploy.yaml
```yaml
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: nginx-deployment # The name of your deployment
  labels:
    app: nginx  # The label of your deployment
spec:
  replicas: 3 # Number of replicated pods
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

