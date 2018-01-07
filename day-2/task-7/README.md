# Task-7: Add ConfigMap and Secrets data to a Volume
1. Create ConfigMap in yaml file using **kubectl create --save-config -f app-config.yaml** command
  > * You can use bellow [Specifications Examples](#specifications-examples) to define config yaml file
  > * The ConfigMap should contain a file named **settings.yml**. The content of that file should be as follow:
  ```yaml
  env: production
  files:
    enable: true
    provider: local
    local:
      dir: uploads
  ```
2. Update Lets-Chat-App Deployment to take that ConfigMap as a Volume
  > * The Volume Mount in the container for this file should be: /usr/src/app/config
  > * Open Browser and make sure the upload-files feature is enabled and you are able to upload images in a chat room
3. Create Secret in yaml file using **kubectl create --save-config -f app-secret.yaml** command
  > * The Secret should contain a file named **secret.key**. The content of that file should be as follow: Note the value should be in base64
  ```
-----BEGIN CERTIFICATE REQUEST-----
MIIB9TCCAWACAQAwgbgxGTAXBgNVBAoMEFF1b1ZhZGlzIExpbWl0ZWQxHDAaBgNV
BAsME0RvY3VtZW50IERlcGFydG1lbnQxOTA3BgNVBAMMMFdoeSBhcmUgeW91IGRl
Y29kaW5nIG1lPyAgVGhpcyBpcyBvbmx5IGEgdGVzdCEhITERMA8GA1UEBwwISGFt
aWx0b24xETAPBgNVBAgMCFBlbWJyb2tlMQswCQYDVQQGEwJCTTEPMA0GCSqGSIb3
DQEJARYAMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCJ9WRanG/fUvcfKiGl
EL4aRLjGt537mZ28UU9/3eiJeJznNSOuNLnF+hmabAu7H0LT4K7EdqfF+XUZW/2j
RKRYcvOUDGF9A7OjW7UfKk1In3+6QDCi7X34RE161jqoaJjrm/T18TOKcgkkhRzE
apQnIDm0Ea/HVzX/PiSOGuertwIDAQABMAsGCSqGSIb3DQEBBQOBgQBzMJdAV4QP
Awel8LzGx5uMOshezF/KfP67wJ93UW+N7zXY6AwPgoLj4Kjw+WtU684JL8Dtr9FX
ozakE+8p06BpxegR4BR3FMHf6p+0jQxUEAkAyb/mVgm66TyghDGC6/YkiKoZptXQ
98TwDIK/39WEB/V607As+KoYazQG8drorw==
-----END CERTIFICATE REQUEST-----
  ```
4. Update Lets-Chat-APP Deployment to take that Secret as a Volume
  > * The Volume Mount in the container for this file should be: /usr/src/app/docker
  > * Use **kubectl exec -it pod-name bash** to enter the pod and see if the secret and config are in their mount-path and the secret is decrypted
5. Now, change Lets-Chat-App Deployment to take the Secret and the ConfigMap as a Volume projected so secret.key and settings.yml will be in same directory
  > * The Volume Mount in the container for both file should be: /usr/src/app/config
  
### Specifications Examples
#### configmap-complex.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-config
data:
  # example of a complex property defined using --from-file
  example.property.file: |-
    property.1=value-1
    property.2=value-2
    property.3=value-3
```
#### pod-with-configmap-volume.yaml
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
      volumeMounts:
      - name: my-config
        mountPath: /etc/config
  volumes:
    - name: my-config
      configMap:
        name: example-config
  restartPolicy: Never
```
#### secret.yaml
First get the values in base64:
```bash
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
  secret.key: MWYyZDFlMmU2N2Rm
```
#### pod-with-secret-volume.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
  volumes:
  - name: foo
    secret:
      secretName: mysecret
      defaultMode: 256
```
#### pod-with-projected-volume.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
  volumes:
  - name: foo
    projected:
      defaultMode: 256
      sources:
      - secret:
          name: mysecret
      - configMap:
          name: example-config
```

