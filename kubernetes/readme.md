# Kubernetes Implementation --

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

(When a container is deployed and it goes down, by default with no restsrt policy the container will not be up(running). During high traffic there is a need of high availability for the containers to handle trreffic and container can handle a set traffic at once i.e. single cpoy of a conatiner is not enough. In these casees we need both scaling and healing)

## Scaling 
Scaling is the mechanism where kubernetes will run set number of replicas, will scale up and scale down if set so. Kubernetes will stay true to the set number and mentains the set number of replicas.

In other words **Scaling** is where the **set number of replicas are menatined** and scaled up or downn as desired based on the demand, where the **total number of pods are controlled**.

## Healing 
Healing is the mechanism where kubernetes replaces failed or unhealthy pods so that the total number of replicas is set at the desired count. 

The process of **replacing the failed and unhealthy pods** to again menatin the total number of desired replicas is **healing**.

__________________________________________________________________________________________________________________________________________________________________________________

Deployment is a resource in kubernetes, when a microservece is deployed the deployment resource will create a intermediate resource called **replica set**, this replica set will spin up the pods/caontiners in kubernetes.

Example: If we set 'replica set: 3' in deploy.yaml file the replica set will spin up 3 pods, it make sure the pod count stay 3 all the time, and if a pod goes down the replica set will spin up a new pod to mentain that 3 count. 

