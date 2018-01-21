#!/bin/bash

echo "Going to setup cluster for k8s-training/day-2"
for svc in *-svc.yaml ; do
	kubectl create -f $svc
done

for deploy in *-deploy.yaml ; do
	kubectl create -f $deploy
done

watch kubectl get po

