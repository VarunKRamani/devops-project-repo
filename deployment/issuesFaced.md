# Record of Issues faced

## The tooling version was incompatible.
- Helm chats issue while installing AWS load balancer controller.
- Helm kept throwing: `Error: This command needs 1 argument: chart name`
- What was investigated: The root cause was the helm version that was being used was version 2.x.x  which does not support AWS LBb controller.
- Where AWS Load Balancer Controller charts require Helm v3. Modern Kubernetes Helm charts are designed around Helm v3 behavior.
- To fix this issue, helm v2.x.x was removed, installed v3, Re-added repo, update repo and re-ran installation.
____
**Cutting off the resources.**
- Once the project was deployed, the resources were destroyed.
- Starting with kubernetes resorces, to delete kubernetes manifest, run `kubectl delete -f complete-deploy.yaml` and `kubectl delete -f serviceaccount.yaml`.
- Once the manfest are deleted, we move to destroy the infra built for the project. 
- As the infrastructure was created using **Terraform**, destroying the resources was much eassier.
- Once the K8s resources were deleted, run `terraform destroy` to deleted 32 resources.
- **The `terrafrom destroy` loop --** 
- The issue was all 32 resources from terrafrom command were not deleted initally.
- Possible reasons - there were some resources that were deleted manuanlly. Namely -- > Security groups and Elastic Load Balancer
- Kubernetes creates external cloud **load balancers** for the public microservices that aren't tracked in the local Terraform state file. Will have to delete them manually in the console because Terraform cannot remove the underlying subnets while traffic-routing hardware is actively attached to them.
- EKS automatically provisions **security groups** for node-to-node communication that often reference each other in a loop. Will have to delete them manually to clear the dependency before the parent VPC can be dropped.
- The active network cards sitting in your public subnets that were attached to the load balancer and EKS worker nodes. Had to Force Detach and delete them when they stayed stuck in an in-use status.

- EXACT EXP OF AFTER DELETING WHAT 11 RESOURCES WERE REMAINING AND LAST 5 RESOURCES WERE DESTROYED AFTER DELETING THE SECURITY GROUPS WITH THE PICS TO BE ATTACHED. 
