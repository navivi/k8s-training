# Task-13: Use Lets-Chat chart-of-charts To Install/Upgrade

In this task we will install Lets-Chat complete application using helm chart. 

1. First you should delete the previous helm release of Lets-Chat-Web using **helm delete --purge release-name**
2. Then you should delete the Lets-Chat-App and Lets-Chat-Db **deployment**, **service**, **ingress**   ,**configmap**, **secret** and **pvc**.
3. Install Lets-Chat chart-of-charts 
  > * You can install Lets-Chat as follow:
```bash
cd k8s-training/charts/lets-chat
helm install --name lc .
```
  > * Verify all pods are up and running and you can access the application on http://k8s-training.com
4. Now upgrade the image of Lets-Chat-Web and disable logrotate second container
  > * You can add to values.yaml
```yaml
web: 
  image: navivi/lets-chat-web:v2
  logrotate:
    enabled: false
```
  > * Update using `helm upgrade lc .`
  > * Run `watch kubectl get po -l release=lc` to see the upgrade occurs.

 
