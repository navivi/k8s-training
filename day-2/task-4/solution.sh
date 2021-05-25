#!/bin/bash
RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m' 
NC='\033[0m' # No Color

clean(){
  local lc_deploy=$(kubectl get deploy | grep lc-web  | awk '{print $1}') >> /dev/null
  if [[ -n ${lc_deploy} ]]; then
    echo "\$ kubectl delete deploy ${lc_deploy}"
    kubectl delete deploy ${lc_deploy}
  fi

  local lc_svc=$(kubectl get svc | grep lc-web | awk '{print $1}') >> /dev/null
  if [[ -n ${lc_svc} ]]; then
    echo "\$ kubectl delete svc ${lc_svc}"
    kubectl delete svc ${lc_svc}
  fi

  local lc_deploy=$(kubectl get deploy | grep lc-app  | awk '{print $1}') >> /dev/null
  if [[ -n ${lc_deploy} ]]; then
    echo "\$ kubectl delete deploy ${lc_deploy}"
    kubectl delete deploy ${lc_deploy}
  fi

  local lc_svc=$(kubectl get svc | grep lc-app | awk '{print $1}') >> /dev/null
  if [[ -n ${lc_svc} ]]; then
    echo "\$ kubectl delete svc ${lc_svc}"
    kubectl delete svc ${lc_svc}
  fi

  local lc_deploy=$(kubectl get deploy | grep lc-db  | awk '{print $1}') >> /dev/null
  if [[ -n ${lc_deploy} ]]; then
    echo "\$ kubectl delete deploy ${lc_deploy}"
    kubectl delete deploy ${lc_deploy}
  fi

  local lc_svc=$(kubectl get svc | grep lc-db | awk '{print $1}') >> /dev/null
  if [[ -n ${lc_svc} ]]; then
    echo "\$ kubectl delete svc ${lc_svc}"
    kubectl delete svc ${lc_svc}
  fi


  rm -f web-deploy.yaml
  rm -f svc-deploy.yaml
  rm -f app-deploy.yaml
  rm -f app-svc.yaml
  rm -f db-deploy.yaml
  rm -f db-svc.yaml
}

write-db-deploy-yaml(){
  rm -f db-deploy.yaml
  cat > db-deploy.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lc-db # The name of your deployment
  labels:
    app: lc-db  # The label of your deployment
spec:
  replicas: 1 # Number of replicated pods
  selector:
    matchLabels:
      app: lc-db # defines how the Deployment finds which Pods to manage. Should match labels defined in the Pod template
  template:
    metadata:
      labels:
        app: lc-db # The label of the pod to match selectors
    spec:
      containers:
      - name: lc-db # The container name
        image: mongo # The DockerHub image
        ports:
        - containerPort: 27017 # Open pod port 80 for the container
EOF
  cat db-deploy.yaml
}

write-db-svc-yaml(){
  rm -f db-svc.yaml
  cat > db-svc.yaml <<EOF
kind: Service
apiVersion: v1
metadata:
  name: lc-db  # The name of your service
spec:
  selector:
    app: lc-db  # defines how the Service finds which Pods to target. Should match labels defined in the Pod template
  ports:
  - protocol: TCP
    port: 27017 # The service port
    targetPort: 27017 # The pods port
EOF
  cat db-svc.yaml
}

write-app-deploy-yaml(){
  rm -f app-deploy.yaml
  cat > app-deploy.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lc-app # The name of your deployment
  labels:
    app: lc-app  # The label of your deployment
spec:
  replicas: 1 # Number of replicated pods
  selector:
    matchLabels:
      app: lc-app # defines how the Deployment finds which Pods to manage. Should match labels defined in the Pod template
  template:
    metadata:
      labels:
        app: lc-app # The label of the pod to match selectors
    spec:
      containers:
      - name: lc-app # The container name
        image: navivi/lets-chat-app:v1 # The DockerHub image
        ports:
        - containerPort: 8080 # Open pod port 80 for the container
        env: # [OPTIONAL] add environments values 
        - name: MONGO_HOST
          value: lc-db
        - name: MONGO_PORT
          value: "27017"

EOF
  cat app-deploy.yaml
}

write-app-svc-yaml(){
  rm -f app-svc.yaml
  cat > app-svc.yaml <<EOF
kind: Service
apiVersion: v1
metadata:
  name: lc-app  # The name of your service
spec:
  selector:
    app: lc-app  # defines how the Service finds which Pods to target. Should match labels defined in the Pod template
  ports:
  - protocol: TCP
    port: 8080 # The service port
    targetPort: 8080 # The pods port
EOF
  cat app-svc.yaml
}

write-web-deploy-yaml(){
  rm -f web-deploy.yaml
  cat > web-deploy.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lc-web # The name of your deployment
  labels:
    app: lc-web  # The label of your deployment
spec:
  replicas: 3 # Number of replicated pods
  selector:
    matchLabels:
      app: lc-web # defines how the Deployment finds which Pods to manage. Should match labels defined in the Pod template
  template:
    metadata:
      labels:
        app: lc-web # The label of the pod to match selectors
    spec:
      containers:
      - name: lc-web # The container name
        image: navivi/lets-chat-web:v1 # The DockerHub image
        ports:
        - containerPort: 80 # Open pod port 80 for the container
        env: # [OPTIONAL] add environments values 
        - name: CODE_ENABLED
          value: "false"
        - name: APP_HOST
          value: lc-app
        - name: APP_PORT
          value: "8080"
EOF
  cat web-deploy.yaml
}

write-web-svc-yaml(){
  rm -f web-svc.yaml
  cat > web-svc.yaml <<EOF
kind: Service
apiVersion: v1
metadata:
  name: lc-web  # The name of your service
spec:
  selector:
    app: lc-web  # defines how the Service finds which Pods to target. Should match labels defined in the Pod template
  ports:
  - protocol: TCP
    port: 80 # The service port
    targetPort: 80 # The pods port
  type: NodePort # [OPTIONAL] If you want ClusterIP you can drop this line 
EOF
  cat web-svc.yaml
}

create-deploy(){
  echo -n "\$ kubectl create --save-config -f $1"
  read text
  kubectl create --save-config -f $1
  echo -n "\$ kubectl get deploy"
  read text
  kubectl get deploy
}

create-svc(){
  echo -n "\$ kubectl create -f $1"
  read text
  kubectl create -f $1

  echo -n "\$ kubectl get svc"
  read text
  kubectl get svc
}

get-pods-every-2-sec-until-running(){
  echo -e "${GREEN}Every 2 sec, get pods:${NC}"

  if [[ $2 -eq 3 ]]; then
    pods_running_status="Running Running Running"
  else
    pods_running_status="Running"
  fi

  while read pods_status <<< `kubectl get po | grep $1 | awk '{print $3}' | sed ':a;N;$!ba;s/\n/ /g'`; [[ "$pods_status" != "$pods_running_status" ]]; do
    echo "\$ kubectl get po -o wide --show-labels | grep $1 "
    kubectl get po -o wide --show-labels | grep $1
    sleep 2
    echo "-------------------------------------"
  done  
  echo "\$ kubectl get po -o wide --show-labels"
  kubectl get po -o wide --show-labels | grep $1
}

get-web-svc-node-port(){
  WEB_SVC_PORT=$(kubectl get svc | grep lc-web |awk '{print $5}')
  read web_svc_cluster_port web_node_port <<< ${WEB_SVC_PORT//[:]/ }
  cut -d'/' -f1 <<< $web_node_port
}

curl-each-node(){
  web_node_port=$(get-web-svc-node-port)
  echo -n "\$ curl --write-out %{http_code} --silent --output /dev/null kind-worker:$web_node_port/login"
  read text
  RESULT=$(curl --write-out %{http_code} --silent --output /dev/null kind-worker:$web_node_port/login)
  echo $RESULT
  echo "---------------------------------------------------"
}

clear
echo
echo "████████╗  █████╗  ███████╗ ██╗  ██╗        ██╗  ██╗     "
echo "╚══██╔══╝ ██╔══██╗ ██╔════╝ ██║ ██╔╝        ██║  ██║ ██╗ "
echo "   ██║    ███████║ ███████╗ █████╔╝  █████╗ ███████║ ╚═╝ "
echo "   ██║    ██╔══██║ ╚════██║ ██╔═██╗  ╚════╝ ╚════██║ ██╗ "
echo "   ██║    ██║  ██║ ███████║ ██║  ██╗             ██║ ╚═╝ "
echo "   ╚═╝    ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝             ╚═╝     "
echo


echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "1. Create a Deploy and a Service to Lets-Chat-DB microservice"
echo -e "    using kubectl create -f db-deploy.yaml db-svc.yaml command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Cleaning first..................${NC}"
clean
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Writing db-deploy.yaml file:${NC}"
echo "----------------------------------------------"
write-db-deploy-yaml
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Create the db Deployment:${NC}"
create-deploy db-deploy.yaml
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Writing db-svc.yaml file:${NC}"
echo "----------------------------------------------"
write-db-svc-yaml
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Create the db Service:${NC}"
create-svc db-svc.yaml
echo -n "Next >>"
read text
clear
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running lc-db
echo -n "Next >>"
read text
clear
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "2. Create a Deploy and a Service to Lets-Chat-APP microservice "
echo -e "    using kubectl create -f app-deploy.yaml app-svc.yaml command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing app-deploy.yaml file:${NC}"
echo "----------------------------------------------"
write-app-deploy-yaml
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Create the app Deployment:${NC}"
create-deploy app-deploy.yaml
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Writing app-svc.yaml file:${NC}"
echo "----------------------------------------------"
write-app-svc-yaml
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Create the app Service:${NC}"
create-svc app-svc.yaml
echo -n "Next >>"
read text
clear
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running lc-app
echo -n "Next >>"
read text
clear
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "3. Update the previous Deploy of Lets-Chat-Web to "
echo -e "    connect to Lets-Chat-App service using kubectl apply -f web-deploy.yaml${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing web-deploy.yaml file:${NC}"
echo "----------------------------------------------"
write-web-deploy-yaml
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Create the web Deployment:${NC}"
create-deploy web-deploy.yaml
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Writing web-svc.yaml file:${NC}"
echo "----------------------------------------------"
write-web-svc-yaml
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Create the web Service:${NC}"
create-svc web-svc.yaml
echo -n "Next >>"
read text
clear
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running lc-web 3
echo -n "Next >>"
read text
clear
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "4. Open the service on the Node Port and access the login page.${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Going to curl the Service on each node:${NC}"
curl-each-node
