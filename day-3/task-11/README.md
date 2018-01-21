# Task-11: Dynamic Provisioning for Lets-Chat-APP and Lets-Chat-DB
In this task we would like the PersistentVolume of Lets-Chat-App and Lets-Chat-DB will be dynamically provisioned.

1. First delete the previous PersistentVolume and PersistentVolumeClaim created in last task
   - using `kubectl delete pvc pvc-name` and `kubectl delete pv pv-name` 
2. Since NFS and hostPath dont provide internal provisioner (shipped alongside Kubernetes) 
   - we should first install provisioners for them.
  > * You can install the provisioners as follow:
      ```bash
      cd k8s-training/charts/provsioner
      helm init
      helm install --name myp .
      ```
  > * Verify they are up and running using `kubectl get po -n kube-system -l release=myp`
  > * Verify you got 2 StorageClasses: **managed-hostpath-storage**,**managed-nfs-storage** 
      - using `kubectl get storageclass` 
3. Create PersistentVolumeClaim for Lets-Chat-DB using **kubectl create -f db-pvc.yaml** command
  > * The db-pvc accessModes should be **ReadWriteOnce**
  > * You should use the storageClassName **managed-hostpath-storage** - which was created in step 2.
  > * Make sure the PersistentVolumeClaim is bounded and PersistentVolume was created for it -
      using **kubectl get pvc** and **kubectl get pv** 
4. Update the Lets-Chat-DB Deployment and volume of type persistentVolumeClaim. 
   Also, you may remove the nodeSelector from the deployment
  > * After `kubectl apply -f db-deploy.yaml` make sure the DB pod is up and running
5. Create PersistentVolumeClaim for Lets-Chat-App using **kubectl create -f app-pvc.yaml** command
  > * The app-pvc accessModes may be **ReadWriteMany**
  > * You should use the storageClassName **managed-nfs-storage** - which was created in step 2.
  > * Make sure the PersistentVolumeClaim is bounded and PersistentVolume was created for it -
      using **kubectl get pvc** and **kubectl get pv** 
6. Update the Lets-Chat-App deployment by adding it as a Volume the PersistentVolumeClaim
  > * After `kubectl apply -f app-deploy.yaml` make sure the App pod is up and running
5. Check in Browser, even after restart - the data and uploads in chat remain

  
### Specifications Examples

#### pvc.yaml
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-claim
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Mi
  storageClassName: my-storage
```

#### pod-with-pvc.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: redis
    role: master
  name: test-storageos-redis-pvc
spec:
  containers:
    - name: master
      image: kubernetes/redis:v1
      env:
        - name: MASTER
          value: "true"
      ports:
        - containerPort: 6379
      resources:
        limits:
          cpu: "0.1"
      volumeMounts:
        - mountPath: /redis-master-data
          name: redis-data
  volumes:
    - name: redis-data
      persistentVolumeClaim:
        claimName: my-claim
```

