# Kubernetes --

- Service Account
- Deployment and service discovery
- Deploy the project and expose it to public with load balancer type
- Load balancer vs Ingress
- Ingress controller.

## Service Account

**Service Account gives a pod it's identity. It basically tell the pod who it is when talking with kubernetes API.**

Kubernetes need a way to identify the pod and what it is allowed to do. **Service account is a like user account but for pods.**

In Kubernetes every Namespace has a **default** service account, when pod is not assigned with a service account the kubernetes will automatically assign thid **default service account** to the pod with default permissions.

The pods run inside these namespaces, some are already created by Kubernetes when the cluster starts. 

The preexisting namesapces are:
- `default` → Where your apps go if you don’t specify a namespace
- `kube-system` → Internal Kubernetes components 
- `kube-public` → Public cluster info
- `kube-node-lease` → Node heartbeat tracking

Other then these, we can create our own namespaces with a command `kubectl create namespace name_of_namespace_needed` and once run we can check it with `kubectl get ns`. There is also a role and role binding process for the service account for elecated permissions.
As we know containers are ephemeral in nature we need healing. 


## Deployment
**Deployment takes care of both auto Scaling and Healing.**

**Deployment** is a resource in kubernetes, when a microservece is deployed the deployment resource will create a intermediate resource called **replica set**, this replica set will spin up the pods/caontiners in kubernetes.

(When a container is deployed and it goes down, by default with no restart policy the container will not be up(running). During high traffic there is a need of high availability for the containers to handle trreffic and container can handle a set traffic at once i.e. single cpoy of a conatiner is not enough. In these cases we need both scaling and healing)

Example: If we set 'replica set: 3' in deploy.yaml file the replica set will spin up 3 pods, it make sure the pod count stay 3 all the time, and if a pod goes down the replica set will spin up a new pod to mentain that 3 count. 

## Scaling 
Scaling is the mechanism where kubernetes will run set number of replicas, will scale up and scale down if set so. Kubernetes will stay true to the set number and mentains the set number of replicas.

In other words **Scaling** is where the **set number of replicas are menatined** and scaled up or downn as desired based on the demand, where the **total number of pods are controlled**.

## Healing 
Healing is the mechanism where kubernetes replaces failed or unhealthy pods so that the total number of replicas is set at the desired count. 

The process of **replacing the failed and unhealthy pods** to again menatin the total number of desired replicas is **healing**.

_____

## Service and Service Discovery

A kubernetes service is a stable address/endpoint, a name or ip that helps us reach the a group of pods easily, even as those pods stop, start or change.

Service work on the concept called Labels and Selectors. Lablels are nothing but tags or key-value pairs that are attached to the pods and the service resource uses selectors to find the pod with the right lable and routes the traffic to it.

So, when a pod goes down and a new one is created (usually by a Deployment), the Service automatically picks up the new pod. This is because the **Service is always watching for pods that match its selector**. As soon as the **new pod comes up and has the right labels**, the Service automatically starts routing traffic to it. This is how the **Service Discoverty** works.

_This is how the deployment is solving the problem of scaling and healing and service is solving the problem of service discovery._


___
## Writing a Kubernetes file 

We have different types of resources in Kuberentes. Will start the file by :
**deploy.yaml**
```
apiversion: apps/v1
kind: Deployment
matadata:
  name: 'application_name'
  lables:
```
are common accross all kubernetes resource.

- `apiversion` --> Tells Kubernetes which API version this object belongs to.
- `kind` --> Tells Kubernetes what resource you are creating.
- `metadata` --> Identity of the object. Used for naming, grouping and selecting resources.

## Deployment Resource Structue.
Next section is `spec` which differes from rsources to rsources.

```
spec:
  replicas: 1
  selectors:
     matchLabels:
  template: 
    metadata:
        lables: 'these lables are used during service discovery'
     spec:
      serviceAccountName: 'service-account-name,creted-for-this-pod-to-be-assigned'
      containers:
        - name: 'conatiner-name'
          image: 'image-location-that-is-containerized'
          ports:
          env:
          volumesMounts:
  volumes:
```

- spec --> replicas, selectors and template
- template --> metadata and spec
- template --> spec --> serviceAccountName, containers and volumes
- containers --> name, image, ports env and volumesMounts


- `spec` --> This is where Kubernetes is told how the app should run.
- `replicas` --> How many pods should run.
- `selectors` --> How the deployment identifies its pods.
- `template` -- > The pod realted configurations are put this and everything inside here describes the pod that will be created.
- `lables` -->  under `metadata` is used in service discovery.
- `containers` --> Defines the actual application container. Includes container name, image, ports and env variables
- `volumes` --> volume gives your containers a place to store data outside of the container’s own file system. This means if a pod dies or restarts, the data in the volume stays intact.
___
## Service Resource Structure
**Svr.yaml**
```
apiversion: v1
kind: service
metadata:
  name:
  lables:
```
As mentioned its common for to begin the kubernetes file with the above elements `apiversion` is v1 insted of apps/v1

```
spec:
  type: defines-the-type-of-service
  selectors:
  ports:
    port:
    name:
    targetport:
```

- There are three(3) `type` of service : clusterIp, nodeport and load balancer.
- `type` --> Defines how the service is exposed.
- `selectors` --> Selects which pods receive traffic. (a lable same as in pod resource or in deployment template)
- `ports` --> service port.
- `targetport` --> This the pod container port.
- Traffic Flow :   User request --> service port --> target port

___

## How does it work ??
deploy.yaml :
This files tells kubernetes to run the application i.e. pull the container image, create a Pod, and keep that container running.
So after applying this file, Kubernetes starts the application inside a Pod.

**deploy.yaml → creates the Pod running the application**

svr.yaml :
This makes the application reachable inside the cluster. It creates a Service that provides a stable network endpoint and forwards traffic to the Pod running the application.

svc.yaml → creates a Service that sends traffic to that Pod

In simple words, deployment runs the application and service allows other services or Pods to reach that application.

___
## Types of services:

There are typically three types of services in kubernetes:
1. Cluster IP
2. Node port
3. Load Balancer service type.

The service types of our svc in project was Cluster IP. We need to change it to LB type to access the project/frontend. 

When a cluster is created the kubernetes creates internal network which is cluster network using CNI - container network interface, by default the service type is Cluster IP and it will not be accessable from outside the cluster

- Cluster IP : This exposes the application only inside the Kubernetes cluster. It only allows service to service communication or pod to pod communication within the cluster. This service is extermely secure. It is used in cases where the service should not be explored outside.

- Node Port: This exposes the service outside the cluster using a port on each node.
  
- Load Blancer: This exposes the service using a cloud provider’s load balancer. It unables the public access for the apploaction.

___
## Cons of Taking this **Load Balancer** approach and how to Improve

1. Not Fully Declarative (Provider-Specific Config): Kubernetes creates the load balancer, but advanced configuration is outside Kubernetes control. HTTP → HTTPS, SSL certificates and Advanced routing, these are handled by the cloud provider’s load balancer, not purely by Kubernetes YAML.
2. Cost: Each LoadBalancer service usually creates one cloud load balancer. So multiple services = multiple load balancers = more cost.
3. Each service gets its own external entry point. Ingress is much more efficient.
4. Provider Dependency: LoadBalancer works through the Cloud Controller Manager (CCM).
5. Not Ideal for Large Microservice Systems: If you expose every microservice externally, it becomes messy. 10 services → 10 load balancers, this leads to: high cost, difficult management and complex networking.
