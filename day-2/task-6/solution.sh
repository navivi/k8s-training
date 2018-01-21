#!/bin/bash
RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m' 
NC='\033[0m' # No Color

clean(){
  local lc_config=$(kubectl get cm | grep lc-config  | awk '{print $1}') >> /dev/null
  if [[ -n ${lc_config} ]]; then
    echo "\$ kubectl delete cm ${lc_config}"
    kubectl delete cm ${lc_config}
  fi

  local lc_secret=$(kubectl get secret | grep lc-db | awk '{print $1}') >> /dev/null
  if [[ -n ${lc_secret} ]]; then
    echo "\$ kubectl delete secret ${lc_secret}"
    kubectl delete secret ${lc_secret}
  fi

}

run-previous-task-solution(){
  /bin/bash ../task-5/solution.sh
}


write-db-secret-yaml(){
  cat > db-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: lc-db
type: Opaque
data:
  username: $(echo -n "admin" | base64)
  password: $(echo -n "1f2d1e2e67df" | base64)
EOF

  cat db-secret.yaml
}

write-lc-config-yaml(){
  cat > lc-config.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: lc-config
data:
  code.enabled: "false"
EOF
  cat lc-config.yaml
}

write-db-deploy-yaml(){
  cat > db-deploy.yaml <<EOF
apiVersion: apps/v1beta2
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
EOF

  cat db-deploy.yaml
}

write-app-deploy-yaml(){
  cat > app-deploy.yaml <<EOF
apiVersion: apps/v1beta2
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
        - name: MONGO_USER
          valueFrom:
            secretKeyRef:
              name: lc-db
              key: username
        - name: MONGO_PASS
          valueFrom:
            secretKeyRef:
              name: lc-db
              key: password
EOF
  cat app-deploy.yaml
}

write-web-deploy-yaml(){
  cat > web-deploy.yaml <<EOF
apiVersion: apps/v1beta2
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
        env: # [OPTIONAL] add environments values 
        - name: CODE_ENABLED
          valueFrom:
            configMapKeyRef:
              name: lc-config
              key: code.enabled
        - name: APP_HOST
          value: lc-app
        - name: APP_PORT
          value: "8080"

EOF
  cat web-deploy.yaml
}

create-configmap(){
  echo -n "\$ kubectl create --save-config -f $1"
  read text
  kubectl create --save-config -f $1
  echo -n "\$ kubectl get cm"
  read text
  kubectl get cm
}

create-secret(){
  echo -n "\$ kubectl create --save-config -f $1"
  read text
  kubectl create --save-config -f $1
  echo -n "\$ kubectl get secret"
  read text
  kubectl get secret
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

  while read pods_status <<< `kubectl get po | grep $1 | awk '{print $3}'`; [[ "$pods_status" != "$pods_running_status" ]]; do
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
  for i in `seq 3`; do 
    echo -n "\$ curl --write-out %{http_code} --silent --output /dev/null kube-node-$i:$web_node_port/login"
    read text
    RESULT=$(curl --write-out %{http_code} --silent --output /dev/null kube-node-$i:$web_node_port/login)
    echo $RESULT
    echo "---------------------------------------------------"
  done
}

clear
echo
echo "████████╗  █████╗  ███████╗ ██╗  ██╗         ██████╗      "
echo "╚══██╔══╝ ██╔══██╗ ██╔════╝ ██║ ██╔╝        ██╔════╝  ██╗ "
echo "   ██║    ███████║ ███████╗ █████╔╝  █████╗ ███████╗  ╚═╝ "
echo "   ██║    ██╔══██║ ╚════██║ ██╔═██╗  ╚════╝ ██╔═══██╗ ██╗ "
echo "   ██║    ██║  ██║ ███████║ ██║  ██╗        ╚██████╔╝ ╚═╝ "
echo "   ╚═╝    ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝         ╚═════╝      "
echo

echo -e "${RED}Make sure you run this solution after you successfully executed Task 5 solution${NC}"
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "1. Create ConfigMap in yaml file using **kubectl create --save-config -f lc-config.yaml** command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing lc-config.yaml file:${NC}"
echo "----------------------------------------------"
write-lc-config-yaml
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Create the lets-chat ConfigMap:${NC}"
create-configmap lc-config.yaml
echo -n "Next >>"
read text
clear
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "2. Update Lets-Chat-Web Deployment to take the value of **CODE_ENABLED** from the ConfigMap${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing web-deploy.yaml file:${NC}"
echo "----------------------------------------------"
write-web-deploy-yaml
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Update the web Deployment:${NC}"
apply-change web-deploy.yaml
read text
clear
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running lc-web 3
echo -n "Next >>"
read text
clear
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "3. Create Secret in yaml file using kubectl create --save-config -f db-secret.yaml command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing db-secret.yaml file:${NC}"
echo "----------------------------------------------"
write-db-secret-yaml
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Create the db Secret:${NC}"
create-secret db-secret.yaml
echo -n "Next >>"
read text
clear
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "4. Update Lets-Chat-DB and Lets-Chat-APP Deployments to take the values from the Secret${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing db-deploy.yaml file:${NC}"
echo "----------------------------------------------"
write-db-deploy-yaml "WITH_SECRET"
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Update the DB Deployment:${NC}"
apply-change db-deploy.yaml
read text
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Writing app-deploy.yaml file:${NC}"
echo "----------------------------------------------"
write-app-deploy-yaml "WITH_SECRET"
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Update the App Deployment:${NC}"
apply-change app-deploy.yaml
read text
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Going to curl the Service on each node:${NC}"
curl-each-node


