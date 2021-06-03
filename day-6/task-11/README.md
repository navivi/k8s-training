# Task-11: Expose Lets-Chat on FQDN:80 Using Ingress and Nginx-Controller

***First - Install Ingress Controller on the kind cluster by following the instructions here: [Setting Up An Ingress Controller](https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx)***

In this task we would like to expose Lets-Chat application on port 80 - so we could access the application on http://k8s-training.com

1. Add Ingress with rule to Lets-Chat-Web service using **kubectl create -f web-ingress.yaml**
  > * You can use bellow [Specifications Examples](#specifications-examples) to define web-ingress.yaml
  > * The host to kubernetes cluster is **k8s-training.com**. 
  > * Verify you can access the application on http://k8s-training.com
  > * What happens when you login and try to add new room? Check the browser DevTools (F12)
2. To load balance a WebSocket application with NGINX Ingress controllers, you need to add the nginx.org/websocket-services annotation to your Ingress resource definition. But since the client is connected with WebSocket seesion to the Lets-Chat-App service (and not the Lets-Chat-Web) - You should create another Ingress with rule to Lets-Chat-App
  > * You should add this Ingress the `nginx.org/websocket-services` annotation
  > * The path to the WebSocket is `/socket.io/`

  
### Specifications Examples
#### ingress.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
    - host: my-host.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 80
```

#### ingress-with-websocket-annotation.yaml
```yaml
apiVersion: networking.k8s.io/v1
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
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 8080
```

#### ingress-with-rewrite-annotation.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: my-host.com
      http:
        paths:
          - path: /relative-path
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 8080
```

