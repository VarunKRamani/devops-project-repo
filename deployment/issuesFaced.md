# Record of Issues faced

## The tooling version was incompatible.
- Helm chats issue while installing AWS load balancer controller.
- Helm kept throwing: `Error: This command needs 1 argument: chart name`
- What was investigated: The root cause was the helm version that was being used was version 2.x.x  which does not support AWS LBb controller.
- Where AWS Load Balancer Controller charts require Helm v3. Modern Kubernetes Helm charts are designed around Helm v3 behavior.
- To fix this issue, helm v2.x.x was removed, installed v3, Re-added repo, update repo and re-ran installation.

<img width="800" height="600" alt="Screenshot 2026-05-25 091922" src="https://github.com/user-attachments/assets/f8655e6c-b1bc-462b-ac55-d010738c2606" />

<img width="800" height="600" alt="Screenshot 2026-05-25 091945" src="https://github.com/user-attachments/assets/dd62ce74-1bef-44f4-8ea8-2bfb7c51eb82" />

<img width="800" height="600" alt="Screenshot 2026-05-25 092037" src="https://github.com/user-attachments/assets/4a900acb-95d9-439b-b202-6430ccfdfb41" />

____
**Cutting off the resources.**
- Once the project was deployed, the resources were destroyed.
- Starting with kubernetes resorces, to delete kubernetes manifest, run `kubectl delete -f complete-deploy.yaml` and `kubectl delete -f serviceaccount.yaml`.
- 
<img width="800" height="600" alt="Screenshot 2026-05-23 190826" src="https://github.com/user-attachments/assets/b579a900-9b60-40f1-9650-bd62d2903f85" />

- Once the manfest are deleted, we move to destroy the infra built for the project. 
- As the infrastructure was created using **Terraform**, destroying the resources was much eassier.
<img width="800" height="600" alt="Screenshot 2026-05-23 190911" src="https://github.com/user-attachments/assets/c3c1aa6e-e2c9-469c-8afe-d5a309b5205e" />

- Once the K8s resources were deleted, run `terraform destroy` to deleted 32 resources.
- **The `terrafrom destroy` loop --**

<img width="800" height="600" alt="Screenshot 2026-05-23 191214" src="https://github.com/user-attachments/assets/57557201-4a14-4550-9a4a-4f6a00a2cd73" />

<img width="800" height="600" alt="Screenshot 2026-05-23 191246" src="https://github.com/user-attachments/assets/8903fee9-a063-4fb3-9532-8a9e3491caf9" />

- The issue was all 32 resources from terrafrom command were not deleted initally.
- Possible reasons - there were some resources that were deleted manuanlly. Namely -- > Security groups and Elastic Load Balancer
- Kubernetes creates external cloud **load balancers** for the public microservices that aren't tracked in the local Terraform state file. Will have to delete them manually in the console because Terraform cannot remove the underlying subnets while traffic-routing hardware is actively attached to them.
- EKS automatically provisions **security groups** for node-to-node communication that often reference each other in a loop. Will have to delete them manually to clear the dependency before the parent VPC can be dropped.
- The active network cards sitting in your public subnets that were attached to the load balancer and EKS worker nodes. Had to Force Detach and delete them when they stayed stuck in an in-use status.

- Once the Security groups and Loadbalancer were deleted manually, `terraform destroy` was successful in destroying remaining 5 resources.

<img width="800" height="600" alt="Screenshot 2026-05-23 191352" src="https://github.com/user-attachments/assets/22254f53-cb5c-4ef9-b4f2-277c4154478e" />

<img width="800" height="600" alt="Screenshot 2026-05-23 191452" src="https://github.com/user-attachments/assets/9b5728b3-47d5-48e9-aa68-040578b2759a" />

- All the resoucres were destroyed. 
