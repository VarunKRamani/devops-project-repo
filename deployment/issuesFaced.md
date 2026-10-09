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

  _________________________________________________________________

  # Issues faced on 2nd deployment.

- **EKS cluster creation failed**, **Error message : "InvalidParameterException: AMI for this version 1.30 is not supported".** This error was caused cause of the outdated AMI type.
<img width="800" height="600" alt="image" src="https://github.com/user-attachments/assets/4419eac9-ab80-4943-99ca-2ddbc3c2ad76" />
**Fixes**:
  **ami_type Configuration**, Switched to Amazon Linux 2023 (AL2023_x86_64_STANDARD). Added `ami_type = "AL2023_x86_64_STANDARD"` in modules/eks/main.tf. (Note: ami type was not set Prior, When we don't explicitly set ami_type, AWS defaults to AL2_x86_64 i.e. Amazon Linux 2. Starting with Kubernetes 1.30, AWS officially deprecated Amazon Linux 2 for EKS managed node groups. AWS removed the AL2 base image mappings for version 1.30, making Amazon Linux 2023 the new default and required baseline OS. ) Then `terraform init -upgrade` followed by plan and apply.


<img width="800" height="600" alt="image" src="https://github.com/user-attachments/assets/1eea8e50-0860-4c1a-92b2-6e77ef84593e" />

**Once AMI was set the EKS cluster was formed.** cluster_name="my-eks-cluster"
<img width="800" height="600" alt="image" src="https://github.com/user-attachments/assets/d627a31d-6eee-4450-b958-ad190dd739d1" />

`Kubectl get nodes` to verify the nodes and it's status.
<img width="800" height="600" alt="image" src="https://github.com/user-attachments/assets/f87b1f7b-1781-4cb8-a941-92e1b979b450" />


- Update the curl command to download the JSON policy. `curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json`

- **Helm Installation**: Initially Helm v2.17.0 was installed, when tired to add EKS repository to Helm, we ran into an error. Error message was "Error: could not find tiller".
<img width="512" height="371" alt="image" src="https://github.com/user-attachments/assets/2aac465f-1088-4644-b836-1e43be5ee4e1" />

- **Fixes**:
  Helm v2.xx.x relies on a server-side component called Tiller, which is **deprecated and incompatible with modern Kubernetes clusters**. Upgraded to Helm v3, which is client-only and does not require Tiller.

 

