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
- To check services run `kubectl get svc`.
- Try accesing the frontend using the service Ip address:port, we were not able to access the project/frontend.


## How to access this deployed project ?
We have set the `type: ClusterIP` as service type in the service resource and as we know the clusterIP only allows the internal connection among clusters. We failed to access the frontend. 
Now, 
To be able to access the project we need to change the service type to **LoadBalancer** type, for the project to be accessed by public or external world. 

How, 

The service type of frontendproxy need to be changed :
- Run `kubectl get svc I grep frontendproxy`, get the full name of the service and run `kubectl edit svc opentelemetry—demo—frontendproxy`.
- Change the type to LoadBalancer i.e. `type: LoadBa1ancer`, save and exit.
- Once done the o/p --> `service/opentelemetry—demo-frontendproxy edited`. Wait for 5-10 min.(cause the ccm will speak to aws and create a LB, can be checked in aws console.)
- Get the External Ip using, run `kubectl get svc opentelemetry—demo—frontendproxy` and note the port too.
- Now browse the ExternalIP:port.
- 😀😀 The project is successfully deployed. The application is running on Kubernetes Cluster !!!!!

_**Note**_ : Change the type back to node port `type: NodePort` once deployed and checked. Load balancer costs $.

We came to know how Load balancer service type is not efficient and cost effective. We will deploy the project using ingress Controller.
___
## Deploying Project using Ingress Controller 

- Will start with checking the current cluster `kubectl config current-context`
- We need to create IAM role and assign policy with requried permissions to the IAM role.
- We will connect the service account with IAM role using IAM OIDC provider.
- We need to configure the IAM OIDC provider, run `export cluster_name=<CLUSTER—NAME>`.
- Command to extract the OIDC ID of the EKS cluster. `oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)`
- The OIDC ID will be saver in `oidc_id` variable, to check run `echo $oidc_id`.
- Add the OIDC provider to the cluster, run `eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve`
- Need to create Service accoutn and IAM policy, policy with ELB related permissions, create IAM role and attach that to the service account of ALB controller.
- To get the policy, AWS provides the policy in `.JSON` form. Run `curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json`
- The file will be found run `ls` and find `iam_policy.json` contains all the permissions related to elastic load balancer.
- To create IAM policy run `aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json`. The policy will get created.
- Run `eksctl create iamserviceaccount --cluster=<your-cluster-name> --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::<your-aws-account-id>:policy/AWSLoadBalancerControllerIAMPolicy --approve` this command creates an IAM Service Account for Kubernetes and connects it to an AWS IAM Role. This command gives the AWS Load Balancer Controller permission to manage AWS load balancers from inside the Kubernetes cluster without using AWS access keys. o/p will be --> serviceaccounts that exist in Kubernetes will be excluded, use —-override-existing-serviceaccounts to override

  
- **Install Helm** from using documentataion.
- Add helm repo related to EKS, run `helm repo add eks https://aws.github.io/eks-charts`
- Install the ALB controller `helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=<your-cluster-name> --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=<region> --set vpcId=<your-vpc-id>`. pass the parameters vpc-id, your-cluster-name and region. O/p --> AWS Load Balancer controller installed!
- Verify the pods if up and running, run `kubectl get pods —n kube—system`.
- Verify that the deployments are running, run `kubectl get deployment -n kube-system aws-load-balancer-controller`.

___

Make sure the load balancer is removed --> run `kubectl edit svc opentelemetry—demo—frontendproxy` and change the type back to `type: NodePort`, the load balancer will be deleted automatically 

## Creating the Ingress Resource 
- We are creating for Frontend proxy, go to `~/ultimate-devops—project-demo/kubernetes/frontendproxy$` and create **ingress.yaml** run `vim ingress.yaml`.
- Reffer documentation for annotations. <img width="900" height="80" alt="image" src="https://github.com/user-attachments/assets/9fd5b9b7-9684-48fe-bde2-f7d4a6a1a275" />
- We will be providing a dummy doamin name for now `example.com`, and update the DNS records to test the project deployment. 
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend-proxy
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  ingressClassName: alb
  rules:
    - host: example.com
      http:
        paths:
          - path: "/"
            pathType: Prefix
            backend:
              service:
                name: opentelemetry-demo-frontendproxy
                port:
                  number: 8080
```

- Save the file and run `kubectl apply -f ingress.yaml`, the o/p -->> "ingress.networking.k8s.io/frontend—proxy created"
- The ingress controller read the ingress resource and created a loadbalancer. to check run `kubectl get ing`
- Check the AWS console under loadbalancer, the LB will be created.
- Once the status is `Active`, try running the **DNS name**, the project will not be accessible, it will fail. Cause, in the ingress.yaml file we have said only allow the access from `**example.com**`. As example.com is not a real domain, we need to edit DNS records of the system and then access the project.
- Run `nslookup DNS-name-given-by-loadbalancer`, try running the IPs and DNS names to access the project, it will FAIL. As mentioned only from example.com we can access the project.
- Will change the local DNS records of the local system in our case the VM for testing, run `sudo vim /etc/hosts`. Add the IP from nslookup command and example.com (Ex: 44.55.112.21 example.com) and save. (note: it might not work on some browsers, no need to worry)
- 😀😀 The project is successfully deployed using Ingress !!!!!!!!!!


