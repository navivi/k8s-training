# Task-5: Configure Liveness and Readiness Probes to Pods
1. Add Liveness and Readiness Probes to Lets-Chat-APP yaml file and update with **kubectl apply -f app-deploy.yaml** command
  > * You can use bellow [Specifications Examples](#specifications-examples) to define probes in the yaml file
  > * One way to get Lets-Chat-APP health-check is: `curl app-host:app-port/login`. (But you should use httpGet probe. Not curl!)
2. Add Liveness and Readiness Probes to Lets-Chat-DB yaml file and update with **kubectl apply -f db-deploy.yaml** command
  > * You may use the health-check command for mongodb: `mongo --eval "db.adminCommand('ping')"`
3. Add Liveness and Readiness Probes to Lets-Chat-Web yaml file and update with **kubectl apply -f web-deploy.yaml** command
  > * One way to get Lets-Chat-Web health-check is: `curl web-host:web-port/media/favicon.ico`. (But you should use httpGet probe. Not curl!)
4. Create a health problem in the Lets-Chat-App pod and verify it is becoming Unhealthy and goes throw self healing.
  > * Delete the media folder inside the Lets-Chat-App pod. You can use **kubectl exec -it pod-name -- rm -rf media**
  > * Verify the pod is Unhealthy - using **kubectl describe pod-name** and **kubectl get po**
  > * Verfiy the Browser is not responding with Exception stacktrace, but waiting for the Backend to respond.
  > * Verify the pod was auto restarted and became healthy again
  
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
