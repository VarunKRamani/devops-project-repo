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



