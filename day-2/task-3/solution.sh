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

  rm -f web-deploy.yaml
  rm -f svc-deploy.yaml
}

write-web-deploy-yaml(){
  VERSION=$1
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
        version: ${VERSION} # added a second label
    spec:
      containers:
      - name: lc-web # The container name
        image: navivi/lets-chat-web:${VERSION} # The DockerHub image
        ports:
        - containerPort: 80 # Open pod port 80 for the container
        env: # [OPTIONAL] add environments values 
        - name: CODE_ENABLED
          value: "false"
EOF
	cat web-deploy.yaml
}

create-web-deploy(){
  echo -n "\$ kubectl --save-config create -f  web-deploy.yaml"
  read text
	kubectl create --save-config -f  web-deploy.yaml
  echo -n "\$ kubectl get deploy"
  read text
  kubectl get deploy
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
  type: LoadBalancer # [OPTIONAL] If you want ClusterIP you can drop this line 
EOF
	cat web-svc.yaml
}

create-web-svc(){
  echo -n "\$ kubectl create -f web-svc.yaml"
  read text
	kubectl create -f web-svc.yaml

  echo -n "\$ kubectl get svc"
  read text
	kubectl get svc
}

get-pods-every-2-sec-until-running(){
  echo -e "${GREEN}Every 2 sec, get pods:${NC}"
  while read pods_status <<< `kubectl get po | grep lc-web- | awk '{print $3}' | sed -e ':a' -e 'N;$!ba' -e 's/\n/ /g'`; [[ $pods_status != "Running Running Running" ]]; do
    echo "\$ kubectl get po -o wide --show-labels"
    kubectl get po -o wide --show-labels
    sleep 2
    echo "-------------------------------------"
  done  
  echo "\$ kubectl get po -o wide --show-labels"
  kubectl get po -o wide --show-labels
}

curl-service(){
  while read web_ext_ip <<< `kubectl get svc | grep lc-web |awk '{print $4}'`; [[ $web_ext_ip == "<none>" ||  $web_ext_ip == "<pending>" ]]; do
    echo "Pending external IP"
    sleep 2
    echo "-------------------------------------"
  done  
  echo "got external ip: $web_ext_ip"
  
  echo -n "\$ curl --write-out %{http_code} --silent --output /dev/null $web_ext_ip/media/favicon.ico"
  read text
  RESULT=$(curl --write-out %{http_code} --silent --output /dev/null $web_ext_ip/media/favicon.ico)
  echo $RESULT
  echo "---------------------------------------------------"
}

check-logs-in-pods(){
  for pod in `kubectl get po | grep lc-web | awk '{print $1}'`; do
    echo -n "\$ kubectl logs $pod"
    read text
    kubectl logs $pod
    echo "---------------------------------------------------"
  done
}

apply-web-deploy(){
  echo -n "\$ kubectl apply -f web-deploy.yaml"
  read text
  kubectl apply -f web-deploy.yaml
  sleep 1
}

rollout-undo(){
  echo -n "\$ kubectl rollout undo deployment lc-web"
  read text
  kubectl rollout undo deployment lc-web
  sleep 1
}
clear
echo
echo "████████╗  █████╗  ███████╗ ██╗  ██╗        ██████╗      "
echo "╚══██╔══╝ ██╔══██╗ ██╔════╝ ██║ ██╔╝        ╚════██╗ ██╗ "
echo "   ██║    ███████║ ███████╗ █████╔╝  █████╗  █████╔╝ ╚═╝ "
echo "   ██║    ██╔══██║ ╚════██║ ██╔═██╗  ╚════╝  ╚═══██╗ ██╗ "
echo "   ██║    ██║  ██║ ███████║ ██║  ██╗        ██████╔╝ ╚═╝ "
echo "   ╚═╝    ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝        ╚═════╝      "
echo

echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "1. Delete the previous Deployment, using kubectl delete deploy command, of Lets-Chat-Web microservice "
echo -e "   and create new Deployment using kubectl create -f web-deploy.yaml command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Cleaning first..................${NC}"
clean
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Writing web-deploy.yaml file:${NC}"
echo "----------------------------------------------"
write-web-deploy-yaml v1
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Create the new Deployment:${NC}"
create-web-deploy
echo -n "Next >>"
read text
clear
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "2. Create a Service to Lets-Chat-Web microservice using kubectl create -f web-svc.yaml command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing web-svc.yaml file:${NC}"
echo "----------------------------------------------"
write-web-svc-yaml
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Create the new Service:${NC}"
create-web-svc
echo -n "Next >>"
read text
clear
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "3. Verify the pods are ready and you are able to access Lets-Chat-Web UI via browser${NC}"
echo -n ">>"
read text
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Going to curl the Service:${NC}"
curl-service
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Checking the logs of each pod:${NC}"
check-logs-in-pods
echo -n "Next >>"
read text
clear
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "4. Update the deployment, using kubectl apply -f web-deploy.yaml command, and change the image to "
echo -e "    navivi/lets-chat-web:v2 and also change the label to version: v2 in spec.template.labels${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Changing web-deploy.yaml file:${NC}"
echo "----------------------------------------------"
write-web-deploy-yaml v2
echo "----------------------------------------------"
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Apply the changed Deployment:${NC}"
apply-web-deploy
echo -n "Next >>"
read text
clear
echo -ne "${GREEN}Verify the update :${NC}"
get-pods-every-2-sec-until-running
echo -n "Next >>"
read text
clear
echo -e "${GREEN}Checking the logs of each pod:${NC}"
check-logs-in-pods
echo -n "Next >>"
read text
clear
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "4. Rollback to the previous deployment using kubectl rollout undo deployment deploy-name${NC}"
echo -n ">>"
read text
rollout-undo
echo -n "Next >>"
read text
clear
echo -ne "${GREEN}Verify the rollout undo :${NC}"
get-pods-every-2-sec-until-running


