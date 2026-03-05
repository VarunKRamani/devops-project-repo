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

## Deployment

what it does? --> Deployment takes care of both auto Scaling and Healing. 
