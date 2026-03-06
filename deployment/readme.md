## Project deployment details.

Will be adding prerequisits, problems faces and other actions took while deploying this peoject.

# Docker

# Terraform

- Once the S3, DynamoDB is created.
- Clone the repo or move the file to the VM.
- Run `terraform init`, which will configure it --> (message will be) 'Successfully configured the back end "s3"! terraform will automatically use this backend unless the backend configuration changes'. So we have used the remote backend resulting in solving the the state locking and remote state management problem.
- Run `terraform plan` --> it will acquire the sate lock and o/p will be 'Plan: 32 to add, 0 to change, 0 to destroy'. The reaources being created will be listed in the plan.
- Run `terraform apply` --> Enter a value : type "yes". Now the terraform will start forming/creating and will take some time. (message will be) --> Apply complete! Resource: 32 added, 0 changed, 0 destroyed. and the output will be displayed.
- later can be varified on AWS console.
- Remember -- the cost clock will start, make sure to move to next k8s deployment if not run `terraform destroy`.
## Connecting to the cluster-
- Once the EKS cluster is created. 
how to access it from our ec2/VM ? --> 
Check the eks cluster created with `kubectl get nodes`.

- We need to update the kubeconfig file with the cluster information.
(need to AWS CLI and configure it with `aws configure`).

- Run the command `aws eks update-kubeconfig --region region-code --name cluster-name`, region-code and cluster-name have to be added to the command. if done o/p --> "Added new context ___"
- Now run `kubectl config view` --> o/p all the details of the EKS cluster.
- To check the current context, run `kubectl config current-context`

# Kubernetes

To deploy the project on kubernetes--

- Make sure all the requried **resources are created using Terraform.**
- Clone the repository **`ultimate-devops-project-demo`**(already done) to get the deploy.yaml files of the microservices and the **complete-deploy.yaml** file for the deployment.
