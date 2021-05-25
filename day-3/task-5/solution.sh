#!/bin/bash
RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m' 
NC='\033[0m' # No Color

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
        livenessProbe:
          exec:
            command:
            - mongo
            - --eval
            - "db.adminCommand('ping')"
          initialDelaySeconds: 30
          timeoutSeconds: 5
        readinessProbe:
          exec:
            command:
            - mongo
            - --eval
            - "db.adminCommand('ping')"
          initialDelaySeconds: 5
          timeoutSeconds: 1
EOF
  cat db-deploy.yaml
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
        livenessProbe:
          httpGet:
            path: /login
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 5
        readinessProbe:
          httpGet:
            path: /login
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 1
        env: # [OPTIONAL] add environments values 
        - name: MONGO_HOST
          value: lc-db
        - name: MONGO_PORT
          value: "27017"
EOF
  cat app-deploy.yaml
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
        livenessProbe:
          httpGet:
            path: /media/favicon.ico
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 5
        readinessProbe:
          httpGet:
            path: /media/favicon.ico
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 1
EOF
  cat web-deploy.yaml
}

apply-change(){
  echo -n "\$ kubectl apply -f $1"
  read text
  kubectl apply -f $1
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

create-health-problem-in-lc-app-pod(){
  local lc_app_pod_name=$(kubectl get po | grep lc-app | awk '{print $1}')
  echo -n "\$ kubectl exec -it ${lc_app_pod_name} -- rm -rf media"
  read text
  kubectl exec -it ${lc_app_pod_name} -- rm -rf media
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
echo "████████╗  █████╗  ███████╗ ██╗  ██╗        ███████╗     "
echo "╚══██╔══╝ ██╔══██╗ ██╔════╝ ██║ ██╔╝        ██╔════╝ ██╗ "
echo "   ██║    ███████║ ███████╗ █████╔╝  █████╗ ███████╗ ╚═╝ "
echo "   ██║    ██╔══██║ ╚════██║ ██╔═██╗  ╚════╝ ╚════██║ ██╗ "
echo "   ██║    ██║  ██║ ███████║ ██║  ██╗        ███████║ ╚═╝ "
echo "   ╚═╝    ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝        ╚══════╝     "
echo

echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "1. Add Liveness and Readiness Probes to Lets-Chat-APP yaml file and "
echo -e "    update with kubectl apply -f app-deploy.yaml command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing app-deploy.yaml file:${NC}"
echo "----------------------------------------------"
write-app-deploy-yaml
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Update the app Deployment:${NC}"
apply-change app-deploy.yaml
read text
clear
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "2. Add Liveness and Readiness Probes to Lets-Chat-DB yaml file and "
echo -e "    update with kubectl apply -f db-deploy.yaml command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing db-deploy.yaml file:${NC}"
echo "----------------------------------------------"
write-db-deploy-yaml
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Update the db Deployment:${NC}"
apply-change db-deploy.yaml
echo -n "Next >>"
read text
clear
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running lc-app
echo -n "Next >>"
read text
clear
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "3. Add Liveness and Readiness Probes to Lets-Chat-Web yaml file and "
echo -e "    update with kubectl apply -f web-deploy.yaml command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing web-deploy.yaml file:${NC}"
echo "----------------------------------------------"
write-web-deploy-yaml
echo "----------------------------------------------"
read text
echo -e "${GREEN}Update the web Deployment:${NC}"
apply-change web-deploy.yaml
read text
echo -n "Next >>"
read text
clear
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running lc-web 3
echo -n "Next >>"
read text
clear
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "4. Create a health problem in one of the Lets-Chat-App pods and verify it is removed from the Service endpoints.${NC}"
echo -n ">>"
read text
create-health-problem-in-lc-app-pod
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Going to curl the Service on each node:${NC}"
curl-each-node
