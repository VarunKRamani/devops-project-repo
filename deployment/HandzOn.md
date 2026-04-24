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

- During the plan the state lock is acquried. 

<img width="800" height="600" alt="Screenshot 2026-04-17 143235" src="https://github.com/user-attachments/assets/91dbaf88-9352-4d8d-87a0-c0fc28c7fefd" />

- Now run `terraform apply`, to actually create resources in AWS.

<img width="800" height="600" alt="Screenshot 2026-04-22 112418" src="https://github.com/user-attachments/assets/dbfa3116-2124-40c1-81d5-a054a61bb28b" />

- 32 Resources created/added. State lock released once the resource creation is completed.

<img width="800" height="180" alt="Screenshot 2026-04-22 113722" src="https://github.com/user-attachments/assets/02230149-ced0-4de3-95d4-f7f7cac22a33" />

____
## Connecting to the cluster and deploying the project(Ingress)

- Run `aws update-kubeconfig --region us-west-2 --name cluster_name`, o/p --> 'Added new context ___-'
- Check if connect to EKS cluster, run `kubectl config current-context`, o/p --> 'displays the cluster name'
- Get into to the directory '~/ultimate-devops-project-demo/kubernetes'.
- Create a Service account,there is a .yaml file. Run `kubectl apply -f serviceaccount.yaml`, o/p --> 'serviceaccount/opentelemetry-demo created'
- To check, run `kubectl get sa`, o/p --> table with default service account and the created service account 'opentelemetry-demo' with AGE will be displayed.
- Now, run the 'complete-deploy.yaml' file to up all the services, run `kubectl apply -f complete-deploy.yaml`. The services will start getting created then deployments.
- To check, run `kubectl get pods`. **Wait until the status of all the pods come to 'Running'.**
- Check the same for services, run `kubectl get svc`. With the type 'ClusterIP'. Can use `kubectl get all` to list both services and pods.

## Accessing the project 
- To Access FrontEnd, we need to change the service type of the frontendproxy, run `kubectl get svc | grep frontendproxy`.
- Run `kubectl edit svc opentelemetry-demo-frontendproxy`, change the type to `LoadBalancer`. **save and Wait for 5-10 min atleast.**
- Check the AWS console if the Load Balancer is created, and get the DNS once created. or copy idt from the terminal, for that run `kubectl get svc opentelemetry-demo-frontendproxy`. The port is `8080`.
- Browse `DNS:port`, Will be able to access the frontend.
🎉😃🥳

## Ingress **


