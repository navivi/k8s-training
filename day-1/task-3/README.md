#Task-3: Deploy and Discover all Lets-Chat microservices
1. Create a Deploy and a Service to Lets-Chat-DB microservice using ** kubectl create -f db-deploy.yaml db-svc.yaml** command
  + You can use bellow [Specifications Examples](###kubectl-cheat-sheet) to define the yaml files
  + You can use the public latest image. Image name: **mongo**
  + The MongoDB server is listening on port 27017
  + Make sure you create ONLY one relica of this pod
  + The service type of this microservice should not be NodePort - so don't add **type** to yaml
2. Create a Deploy and a Service to Lets-Chat-APP microservice using ** kubectl create -f app-deploy.yaml app-svc.yaml** command
  + The Image name of Lets-Chat-App: **navivi/lets-chat-app:v1**
  + The App Node.js server is listening on port 8080
  + You may configure the Lets-Chat-App with the MongoDB service-name and port by passing it environment variable name: **LCB_DATABASE_URI** and value: mongodb://mongo-service-name:mongo-service-port/letschat
  + The service type of this microservice should not be NodePort - so don't add **type** to yaml
3. Delete the previous Deploy and Service of Lets-Chat-Web microservice and create new Deploy and Service of Lets-Chat-Web using ** kubectl create -f web-deploy.yaml web-svc.yaml** command
  + The Image name of Lets-Chat-Web:  **navivi/lets-chat-web:v1**
  + The Web nginx server is listening on port 80
  + You may configure the Lets-Chat-Web with the Lets-Chat-App service-name and port by passing it 2 environment variables: ** APP_HOST** and **APP_PORT**
  + You should disable the code feature. You may confugre the Lets-Chat-Web with environment variable name: ** CODE_ENABELED** and value "false".
  + The service type of this microservice should be NodePort
4. Open the service on the Node Port and accessthe login page. Create user and login. The Open a different browser and create another user. Verfiy you can chat between the users.
  
###Specifications Examples
<div class="language-yaml highlighter-rouge">nginx-service.yaml<div class="highlight"><pre class="highlight"><code><span class="na">kind</span><span class="pi">:</span> <span class="s">Service</span>
<span class="na">apiVersion</span><span class="pi">:</span> <span class="s">v1</span>
<span class="na">metadata</span><span class="pi">:</span>
  <span class="na">name</span><span class="pi">:</span> <span class="s">nginx</span><span class="c1"> # The name of your service</span>
<span class="na">spec</span><span class="pi">:</span>
  <span class="na">selector</span><span class="pi">:</span>
    <span class="na">app</span><span class="pi">:</span> <span class="s">nginx</span> <span class="c1"> # defines how the Service finds which Pods to target. Should match labels defined in the Pod template</span>
  <span class="na">ports</span><span class="pi">:</span>
  <span class="pi">-</span> <span class="na">protocol</span><span class="pi">:</span> <span class="s">TCP</span>
    <span class="na">port</span><span class="pi">:</span> <span class="s">80</span><span class="c1"> # The service port</span>
    <span class="na">targetPort</span><span class="pi">:</span> <span class="s">9376</span><span class="c1"> # The pods port</span>
  <span class="na">type</span><span class="pi">:</span><span class="s">NodePort</span><span class="c1"> # [OPTIONAL] If you want ClusterIP you can drop this line</span>
</code></pre></div></div>

<div id="nginx-deployment.yaml" class="language-yaml highlighter-rouge">nginx-deploy.yaml<div class="highlight"><pre class="highlight"><code><span class="c1"  >apiVersion</span><span class="pi">:</span> <span class="s">apps/v1beta2</span>
<span class="na">kind</span><span class="pi">:</span> <span class="s">Deployment</span>
<span class="na">metadata</span><span class="pi">:</span>
  <span class="na">name</span><span class="pi">:</span> <span class="s">nginx-deployment</span><span class="c1"> # The name of your deployment</span>
  <span class="na">labels</span><span class="pi">:</span>
    <span class="na">app</span><span class="pi">:</span> <span class="s">nginx</span> <span class="c1"> # The label of your deployment</span>
<span class="na">spec</span><span class="pi">:</span>
  <span class="na">replicas</span><span class="pi">:</span> <span class="s">3</span><span class="c1"> # Number of replicated pods</span>
  <span class="na">selector</span><span class="pi">:</span>
    <span class="na">matchLabels</span><span class="pi">:</span>
      <span class="na">app</span><span class="pi">:</span> <span class="s">nginx</span><span class="c1"> # defines how the Deployment finds which Pods to manage. Should match labels defined in the Pod template</span>
  <span class="na">template</span><span class="pi">:</span>
    <span class="na">metadata</span><span class="pi">:</span>
      <span class="na">labels</span><span class="pi">:</span>
        <span class="na">app</span><span class="pi">:</span> <span class="s">nginx</span><span class="c1"> # The label of the pod</span>
    <span class="na">spec</span><span class="pi">:</span>
      <span class="na">containers</span><span class="pi">:</span>
      <span class="pi">-</span> <span class="na">name</span><span class="pi">:</span> <span class="s">nginx</span><span class="c1"> # The container name</span>
        <span class="na">image</span><span class="pi">:</span> <span class="s">nginx:1.7.9</span><span class="c1"> # The DockerHub image</span>
        <span class="na">ports</span><span class="pi">:</span>
        <span class="pi">-</span> <span class="na">containerPort</span><span class="pi">:</span> <span class="s">80</span><span class="c1"> # Open pod port 80 for the container</span>
        <span class="na">env</span><span class="pi">:<span class="c1"> # [OPTIONAL] add environments values </span></span>
        <span class="pi">-</span> <span class="na">name</span><span class="pi">:</span> <span class="s">SOME_ENV_NAME</span>
         <span class="pi"></span> <span class="na">value</span><span class="pi">:</span> <span class="s">some-env-value</span>
</code></pre></div></div>