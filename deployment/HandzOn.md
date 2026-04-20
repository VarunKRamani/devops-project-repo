# Hands on with the Project

## Setting the Budget -
- Insted of using EC2 from AWS to build infrastructure and access clusters etc, a virtualbox ubuntu VM was used to keep the cost low.
- The project has been set with the budget. This is set keeping in mind of things including project architecture built using terraform, kuberneres clusters and CICD. 
<img width="700" height="400" alt="Screenshot 2026-04-15 132103" src="https://github.com/user-attachments/assets/01781d08-deae-4ca8-a114-a4bd6cd6689e" />

- The Alerts have been set, basing on the resource usage the cost will climb and will be notified if corsses the set limit. 
<img width="800" height="350" alt="Screenshot 2026-04-15 132519" src="https://github.com/user-attachments/assets/5a0ccc95-4072-4498-b9c3-da75b59272ac" />

____
## Creation of S3 and DynamoDB for State Locking -
- Backend configuration wrt terraform, Creation of S3 and DynamoDB.
- The S3 bucker name has been updated wrt to the terraform file and it's 'demo-terraform-aws-varu-eks-state-s3-bucket'
- And the Table name is 'terraform-eks-state-locks'.
- The resouce are created in **(Oregon) us-west-2** region.

<img width="800" height="600" alt="Screenshot 2026-04-15 144215" src="https://github.com/user-attachments/assets/263a7b98-f096-4bd5-b1de-c399487295fa" />

<img width="800" height="600" alt="image" src="https://github.com/user-attachments/assets/afb9ee1e-59fb-4698-ac2a-1285c1459fb1" />
____
## Creation of Infrastructure

- The Resource/Infrastructure requried are created using Terraform. Get into directory '~/Desktop/ Terraform'.

<img width="800" height="600" alt="Screenshot 2026-04-17 143100" src="https://github.com/user-attachments/assets/c0cb5cd0-dccf-4543-b3b5-3483b655d036" />

- Once the initialization is done, `terraform plan` is ran.

<img width="800" height="600" alt="Screenshot 2026-04-17 143155" src="https://github.com/user-attachments/assets/d22b912d-4f10-4e2b-8294-7e3a16598219" />

<img width="800" height="600" alt="Screenshot 2026-04-17 143235" src="https://github.com/user-attachments/assets/91dbaf88-9352-4d8d-87a0-c0fc28c7fefd" />

- Now run `terraform apply`, to actully create resources in AWS.




