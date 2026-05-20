## The Issues faced are recorded here.



Cutting off the resources.
- Once the project was deployed, the resources were destroyed.
- As the infrastructure was created using **Terraform**, destroying the resources was much eassier.
- `terraform destroy`, allthough we need to first delete the Kubernetes Resource.
- To delete k8s resource , run `kubectl delete -f complete-deploy.yaml` and `kubectl delete -f serviceaccount.yaml`.
- Once the K8s resources were deleted, run `terraform destroy` to deleted 32 resources.

- The issue was initally all 32 resources from terrafrom command were not deleted initally.
- Possible reasons - there were some resources that were deleted manuanlly. Namely -- > Security groups and Elastic Load Balancer
- Kubernetes creates external cloud **load balancers** for the public microservices that aren't tracked in the local Terraform state file. Will have to delete them manually in the console because Terraform cannot remove the underlying subnets while traffic-routing hardware is actively attached to them.
- EKS automatically provisions **security groups** for node-to-node communication that often reference each other in a loop. Will have to delete them manually to clear the dependency before the parent VPC can be dropped.
- The active network cards sitting in your public subnets that were attached to the load balancer and EKS worker nodes. Had to Force Detach and delete them when they stayed stuck in an in-use status.
