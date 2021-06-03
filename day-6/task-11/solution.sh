#!/bin/bash
RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m' 
NC='\033[0m' # No Color

write-web-ingress-yaml(){
  rm -f web-ingress.yaml
  cat > web-ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: lc-web
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: k8s-training.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: lc-web
                port:
                  number: 80
EOF
  cat web-ingress.yaml
}

write-app-ingress-yaml(){
  rm -f app-ingress.yaml
  cat > app-ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: lc-app
  annotations:
    nginx.org/websocket-services: "my-ws-service"
spec:
  rules:
    - host: k8s-training.com
      http:
        paths:
          - path: /socket.io/
            pathType: Prefix
            backend:
              service:
                name: lc-app
                port:
                  number: 8080
EOF
  cat app-ingress.yaml
}


apply-change(){
  echo -n "\$ kubectl apply -f $1"
  read text
  kubectl apply -f $1
}


curl-fqdn(){
  echo -n "\$ curl --write-out %{http_code} --silent --output /dev/null $1/login"
  read text
  RESULT=$(curl --write-out %{http_code} --silent --output /dev/null $1/login)
  echo $RESULT
  echo "---------------------------------------------------"
}



clear
echo
echo "████████╗  █████╗  ███████╗ ██╗  ██╗    ███╗ ███╗     "
echo "╚══██╔══╝ ██╔══██╗ ██╔════╝ ██║ ██╔╝     ██║  ██║ ██╗ "
echo "   ██║    ███████║ ███████╗ █████╔╝      ██║  ██║ ╚═╝ "
echo "   ██║    ██╔══██║ ╚════██║ ██╔═██╗      ██║  ██║ ██╗ "
echo "   ██║    ██║  ██║ ███████║ ██║  ██╗     ██║  ██║ ╚═╝ "
echo "   ╚═╝    ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝     ╚═╝  ╚═╝     "
echo

echo -e "${RED}First - Install Ingress Controller on the kind cluster by running: "
echo -e "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml ${NC}"
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "1. Add Ingress with rule to Lets-Chat-Web service ${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing web-ingress.yaml file:${NC}"
echo "----------------------------------------------"
write-web-ingress-yaml
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Update the web Ingress:${NC}"
apply-change web-ingress.yaml
read text
clear
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "2. To load balance a WebSocket application with NGINX Ingress controllers, you need to add the nginx.org/websocket-services annotation to "
echo -e "your Ingress resource definition. But since the client is connected with WebSocket seesion to the Lets-Chat-App service (and not the "
echo -e "Lets-Chat-Web) - You should create another Ingress with rule to Lets-Chat-App${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing app-ingress.yaml file:${NC}"
echo "----------------------------------------------"
write-app-ingress-yaml
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Update the app Ingress:${NC}"
apply-change app-ingress.yaml
read text
echo -e "${GREEN}Going to curl the fqdn:${NC}"
curl-fqdn http://k8s-training.com
read text


