# Task-5: Configure Liveness and Readiness Probes to Pods
1. Add Liveness and Readiness Probes to Lets-Chat-APP yaml file and update with **kubectl apply -f app-deploy.yaml** command
  > * You can use bellow [Specifications Examples](#specifications-examples) to define probes in the yaml file
  > * One way to get Lets-Chat-APP health-check is: `curl app-host:app-port/login`. (But you should use httpGet probe. Not curl!)
2. Add Liveness and Readiness Probes to Lets-Chat-DB yaml file and update with **kubectl apply -f db-deploy.yaml** command
  > * You may use the health-check command for mongodb: `mongo --eval "db.adminCommand('ping')"`
3. Add Liveness and Readiness Probes to Lets-Chat-Web yaml file and update with **kubectl apply -f web-deploy.yaml** command
  > * One way to get Lets-Chat-Web health-check is: `curl web-host:web-port/media/favicon.ico`. (But you should use httpGet probe. Not curl!)
4. Create a health problem in one of the Lets-Chat-App pods and verify it is removed from the Service endpoints.
  > * First scale the Lets-Chat-App to 3 replicaCount.
  > * Delete the media folder inside one of the Lets-Chat-App pods. You can use **kubectl exec -it pod-name -- rm -rf media**
  > * Verify the pod is Unhealth - using **kubectl describe pod-name** 
  > * Verfiy the pod is not in the Ready endpoints of the service - using **kubectl get endpoints app-name**
  > * Run **kubectl port-forward pod-name localport:podport** and see in the Browser the pod 500 response
  > * Verify in the Browser, when using the node-port to the service - you get responses only from other pods
  
### Specifications Examples
#### http-probes.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-http
spec:
  containers:
  - name: liveness
    image: k8s.gcr.io/liveness
    args:
    - /server
    readinessProbe:
      httpGet:
        path: /healthz
        port: 8080
        httpHeaders:
        - name: X-Custom-Header
          value: Awesome
      initialDelaySeconds: 30
      periodSeconds: 3
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
        httpHeaders:
        - name: X-Custom-Header
          value: Awesome
      initialDelaySeconds: 3
      periodSeconds: 3
```
#### exec-probes.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-exec
spec:
  containers:
  - name: liveness
    image: k8s.gcr.io/busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
```
