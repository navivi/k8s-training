# Task-16: Write Helm Chart for Lets-Chat-Web

In this task we will install Lets-Chat-Web using helm chart. (Lets-Chat-App and Lets-Chat-DB will remain as before)
The Lets-Chat-Web will be a simple pod - with one container and no ConfigMap

1. First you should delete the Lets-Chat-Web **deployment**, **service**, **ingress** and **configmap**.
2. Create scaffold chart using **helm create web**
  > * The command will create chart directory with templates of **deployment**, **service** and **ingress**
  > * Update the values.yaml with the image repository and tag of Lets-Chat-Web
  > * Enable the ingress and update the hosts to **my-k8s.att.io**
  > * Update the Probes in templates/deployment.yaml. the httpGet.path shoud be /media/favicon.ico
  > * Add Environment variables to templates/deployment.yaml: **CODE_ENABLED="false"**, **APP_HOST=app-service-name**, **APP_PORT="app-service-port"**
3. Before Install - verify the generated yaml files are valid using `helm install --name release-name --dry-run --debug chart-path`. Where release-name is any name you choose (For example: 'lc'). And chart-path is the path to the created charts direcory.
4. Install Lets-Chat-Web using helm
  > * You can install it using `helm install --name release-name chart-path`. 
  > * If you need to apply changes - you can edit the yaml files and then run `helm upgrade release-name chart-path`
  > * Verify the pod is up and running
  > * Verify you can access the application on http://my-k8s.att.io
5. Move the environment varaibles values from templates/deployment.yaml to values.yaml
  > * You can add to values.yaml
```yaml
env: 
  CODE_ENABLED: false
  APP_HOST: lc-app
  APP_PORT: 8080
```
      And then in templates/deployment.yaml change the value to {{ .Values.env.CODE_ENABLED | quote }}
  > * Update using `helm upgrade release-name chart-path`
6. Now, lets improve the templates/deploment.yaml with loop over the Environment Variables - so we could get the name and the value from values.yaml
  > * You can use helm range for loop:
```yaml
env:
{{- range $name, $value := .Values.env }}
- name: {{ $name }}
  value: {{ $value | quote }}
{{- end }}
```
  > * Update using `helm upgrade release-name chart-path`

 
