## The Issues faced are recorded here.



Cutting off the resources.
- Once the project was deployed, the resources were destroyed.
- As the infrastructure was created using **Terraform**, destroying the resources was much eassier.
- `terraform destroy`, allthough we need to first delete the Kubernetes Resource.
- To delete k8s resource , run `kubectl delete -f complete-deploy.yaml` and `kubectl delete -f serviceaccount.yaml`.
- Once the K8s resources were deleted, run `terraform destroy` to deleted 32 resources.

- The issue was initally all 32 resources from terrafrom command were not deleted initally.
- It was 11 remaining after first command and 5 after second command. -- EXP --- for those to be added. 
