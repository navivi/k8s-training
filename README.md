![Let's Chat](http://i.imgur.com/0a3l5VF.png)

![Screenshot](http://i.imgur.com/C4uMD67.png)
A self-hosted chat app for small teams
#K8s Training with Lets-Chat
In this training we will deploy and scale ** let's chat ** application on kubernetes cluster. Let's Chat is a persistent messaging application that runs on Node.js and MongoDB with Nginx at the front.
```flow
st=>operation: Lets-Chat-Web (Nginx)
op1=>operation: Lets-Chat-App (Node.js)
op2=>operation: Lets-Chat-DB (MongoDB)
e=>end: To admin

st->op1->op2

```
###Tasks
1.  Deploy and Explore Lets-Chat-Web
2.  Expose, Scale and Update Lets-Chat-Web
3.  Deploy and Discover all Lets-Chat microservices
4.  Configure your App
