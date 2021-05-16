#!/bin/bash

echo "Going to setup cluster for k8s-training/day-4"
for secret in *-secret.yaml ; do
	kubectl create -f $secret
done

for config in *-config.yaml ; do
	kubectl create -f $config
done

for svc in *-svc.yaml ; do
	kubectl create -f $svc
done

for deploy in *-deploy.yaml ; do
	kubectl create -f $deploy
done

watch kubectl get po
