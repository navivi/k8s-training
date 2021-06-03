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
        env: # [OPTIONAL] add environments values
        - name: MONGO_INITDB_ROOT_USERNAME
          valueFrom:
            secretKeyRef:
              name: lc-db
              key: username
        - name: MONGO_INITDB_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: lc-db
              key: password
        volumeMounts:
        - name: data
          mountPath: /data/db

      volumes:
      - name: data
        hostPath:
          path: /letschat/data
      nodeSelector:
        app: letschat
EOF
  cat db-deploy.yaml
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

label-node(){
  echo -n "\$ kubectl label node kind-worker app=letschat"
  read text
  kubectl label node kind-worker app=letschat
  echo -n "\$ kubectl get no --show-labels"
  read text
  kubectl get no --show-labels
}

mkdir-in-node(){
  echo -n "\$ docker exec -it kind-worker mkdir -p /letschat/data"
  read text
  docker exec -it kind-worker mkdir -p /letschat/data
  echo -n "\$ docker exec -it kind-worker ls -l /"
  read text
  docker exec -it kind-worker ls -l
  echo -n "\$ docker exec -it kind-worker ls -l /letschat"
  read text
  docker exec -it kind-worker ls -l /letschat
  echo -n "\$ docker exec -it kind-worker ls -l /letschat/data"
  read text
  docker exec -it kind-worker ls -l /letschat/data
}



clear
echo
echo "████████╗  █████╗  ███████╗ ██╗  ██╗      █████╗      "
echo "╚══██╔══╝ ██╔══██╗ ██╔════╝ ██║ ██╔╝     ██╔══██╗ ██╗ "
echo "   ██║    ███████║ ███████╗ █████╔╝      ╚█████╔╝ ╚═╝ "
echo "   ██║    ██╔══██║ ╚════██║ ██╔═██╗           ██╗ ██╗ "
echo "   ██║    ██║  ██║ ███████║ ██║  ██╗     ╚█████╔╝ ╚═╝ "
echo "   ╚═╝    ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝      ╚════╝      "
echo

echo -e "${RED}Make sure you run this solution after you successfully executed Task 8 solution${NC}"
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "1. Add label to one of the nodes ${NC}"
echo -n ">>"
read text
label-node
read text
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "2. Create some directory for mongodb inside the node ${NC}"
echo -n ">>"
read text
mkdir-in-node
read text
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "3. Add nodeSelector to the Lets-Chat-DB Deployment and volume to the hostPath ${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing dc-deploy.yaml file:${NC}"
echo "----------------------------------------------"
write-db-deploy-yaml
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Update the db Deployment:${NC}"
apply-change db-deploy.yaml
read text
clear
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running lc-db 1
echo -n "Next >>"
read text
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "4. Check in Browser, even after restart pod User is persistent ${NC}"
echo -n ">>"
read text
clear
echo -e "${GREEN}Going to curl the Service on each node:${NC}"
curl-each-node
