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
- The file complete-deploy.yaml is available in kuberentes direstory. this consist of all the deployment and service resource in it and even the service account is created(for more info look into the file).
- Connect to the cluster that was created, How --> run `kubectl config current-context`, o/p --> should see the cluster that was created.
- Quick check if any pods containers are running / no previous deployments, How --> run `kubectl get all`
- Get to the path 'ultimate-devops-project-demo/kubernetes'.
- Need to create a service account `vim serviceaccount.yaml` check, and run `kubectl apply —f serviceaccount.yaml`, o/p --> 'serviceaccount/opentelemetry—demo created'. To varify run `kubectl get sa`. Note : If not careated the kubernetes will start using the default service account. 
- Run `terraform apply -f complete-deploy.yaml`. This will start creating the services. list of created services and then deployments will be shown.
- To verify run `kubectl get pods`, make sure **all the pods** are in **running** state.
- To check services run `kubectl get svc`

- How to access this deployed project ? --> 
