# Task-6: Define ConfigMap and Secrets
1. Create ConfigMap in yaml file using **kubectl create --save-config -f lc-config.yaml** command
  > * You can use bellow [Specifications Examples](#specifications-examples) to define config yaml file
  > * The ConfigMap should contain property **code.enabled: false**
2. Update Lets-Chat-Web Deployment to take the value of **CODE_ENABLED** from the ConfigMap
  > * Check what happens when you change the value in the configmap to "true"? Did the value in the pods auto changed?
3. Create Secret in yaml file using **kubectl create --save-config -f db-secret.yaml** command
  > * The Secret should contain properties with user and password to mongodb. Note the value should be in base64
4. Update Lets-Chat-DB and Lets-Chat-APP Deployments to take the values from the Secret
  > * The Lets-Chat-DB should have 2 env variables named: **MONGO_INITDB_ROOT_USERNAME**, **MONGO_INITDB_ROOT_PASSWORD**
  > * The Lets-Chat-App should have another 2 env variables named: **MONGO_USER**, **MONGO_PASS**
  > * Verify The Lets-Chat-App is able to authenticate with the DB, when pods start
  
### Specifications Examples
#### configmap.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  some.key: some.value
```
#### pod-with-configmap.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "env" ]
      env:
        # Define the environment variable
        - name: SPECIAL_LEVEL_KEY
          valueFrom:
            configMapKeyRef:
              # The ConfigMap containing the value you want to assign to SPECIAL_LEVEL_KEY
              name: my-config
              # Specify the key associated with the value
              key: some.key
  restartPolicy: Never
```
#### secret.yaml
First get the values in base64:
```bash
$ echo -n "admin" | base64
YWRtaW4=
$ echo -n "1f2d1e2e67df" | base64
MWYyZDFlMmU2N2Rm
```
The Secret:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=
  password: MWYyZDFlMmU2N2Rm
```
#### pod-with-secret.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: mycontainer
    image: redis
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: username
      - name: SECRET_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: password
  restartPolicy: Never
```

