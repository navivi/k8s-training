# Task-15: Expose Lets-Chat on FQDN:80 Using Ingress and Nginx-Controller

In this task we would like to expose Lets-Chat application on port 80 - so we could access the application on http://my-k8s.att.io

1. Add Ingress with rule to Lets-Chat-Web service using **kubectl create -f web-ingress.yaml**
  > * You can use bellow [Specifications Examples](#specifications-examples) to define web-ingress.yaml
  > * The host to kubernetes cluster is **my-k8s.att.io**. You may change it in /etc/hosts of your VM
  > * Verify you can access the application on http://my-k8s.att.io
  > * What happens when you login and try to add new room? Check the browser DevTools (F12)
2. To load balance a WebSocket application with NGINX Ingress controllers, you need to add the nginx.org/websocket-services annotation to your Ingress resource definition. But since the client is connected with WebSocket seesion to the Lets-Chat-App service (and not the Lets-Chat-Web) - You should create another Ingress with rule to Lets-Chat-App
  > * You should add this Ingress the `nginx.org/websocket-services` annotation
  > * The path to the WebSocket is `/socket.io/`
3. Lets add another application to our cluster - Grafana.
  > * You can install the grafana as follow:
```bash
cd k8s-training/charts/grafana
helm install --name myg stable/grafana -f values.yaml
```
  > * Verify they it is up and running using `kubectl get po -l release=myg`
4. Add Ingress with rule to Grafana service.  
  > * You can get the grafana service name using **kubectl get svc**
  > * The path to grafana should be **/grafana**
  > * Verify you can access the application on http://my-k8s.att.io/grafana

  
### Specifications Examples
#### ingress.yaml
```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
    - host: my-host.com
      http:
        paths:
          - path: /
            backend:
              serviceName: my-service 
              servicePort: 80
```

#### ingress-with-websocket-annotation.yaml
```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.org/websocket-services: "my-ws-service"
spec:
  rules:
    - host: my-host.com
      http:
        paths:
          - path: /
            backend:
              serviceName: my-ws-service 
              servicePort: 8080
```

#### ingress-with-rewrite-annotation.yaml
```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: my-host.com
      http:
        paths:
          - path: /relative-path
            backend:
              serviceName: my-rewrite-service 
              servicePort: 8080
```

