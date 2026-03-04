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

# Kubernetes
