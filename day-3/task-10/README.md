# Task-10: Persist Lets-Chat-APP into External Shared File-System Using **persistentVolumeClaim** Volume
In this task we would like to mount an External Storage to Lets-Chat-App pod so we could persist the upload files.
We will use External NFS server.
1. Start the NFS server on your VM (which is outside the Kubernetes Cluster)
  > * You can start the NFS server using `sudo systemctl start nfs-kernel-server.service`
  > * You can check which directory is exported in `sudo cat /etc/exports`
2. Create PersistentVolume to the External NFS Server using **kubectl create -f pv.yaml** command
  > * You can use bellow [Specifications Examples](#specifications-examples) to define pv yaml file
  > * Your VM server IP is **10.192.0.1** and the path should be as specified in **/etc/exports**
3. Create PersistentVolumeClaim for the PersistentVolume using **kubectl create -f pvc.yaml** command
  > * Make sure the PersistentVolumeClaim is bounded to the PersistentVolume using **kubectl get pv**
4. Update the Lets-Chat-App deployment by adding it as a Volume the PersistentVolumeClaim
  > * The mountPath for persisting uploads should be /usr/src/app/uploads
5. Check in Browser, even after restart - the uploads in chat remain

  
### Specifications Examples
#### pv.yaml
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs
spec:
  storageClassName: my-storage
  capacity:
    storage: 10Mi
  accessModes:
    - ReadWriteMany
  nfs:
    server: 10.192.0.1
    path: "/home/nesia/my-nfs"
```
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
