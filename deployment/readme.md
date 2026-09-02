## Project deployment details.

Will be adding prerequisits, problems faces and other actions took while deploying this peoject.

- Git
- AWS CLI
- Java
- Docker
- Terraform
- Helm
- ArgoCD (CD)

# Docker
- Clone the repo, run `git clone repo-URL`.
- The docker files for all the microservices were written, when needed there have been multi stage docker builds resulting in lighter docker image easier during deployment.
- Different microservices have been coded with different languages, accordingly the docker files haven been written and images are formed.
- To up all the services using docker compose, run file docker-compose.yaml  

# Terraform

- Once the S3, DynamoDB is created.
- Clone the repo or move the file to the VM.
- Run `terraform init`, which will configure it --> (message will be) 'Successfully configured the back end "s3"! terraform will automatically use this backend unless the backend configuration changes'. So we have used the remote backend resulting in solving the the state locking and remote state management problem.
- Run `terraform plan` --> it will acquire the sate lock and o/p will be 'Plan: 32 to add, 0 to change, 0 to destroy'. The reaources being created will be listed in the plan.
- Run `terraform apply` --> Enter a value : type "yes". Now the terraform will start forming/creating and will take some time. (message will be) --> Apply complete! Resource: 32 added, 0 changed, 0 destroyed. and the output will be displayed.
- later can be varified on AWS console.
- Remember -- the cost clock will start, make sure to move to next k8s deployment if not run `terraform destroy`.
_________________
## Connecting to the cluster-
- Once the EKS cluster is created. 
how to access it from our ec2/VM ? --> 
Check the eks cluster created with `kubectl get nodes`.

- We need to update the kubeconfig file with the cluster information.
(need to AWS CLI and configure it with `aws configure`).

- Run the command `aws eks update-kubeconfig --region region-code --name cluster-name`, region-code and cluster-name have to be added to the command. if done o/p --> "Added new context ___"
- Let's break down the command we used `aws ..` we are talking to AWS, `.. eks ..` we need to interact with AWS EKS, `.. update-kubeconfig ..` get the information required to connect `kubectl` to this EKS cluster and update/add it in my local kubeconfig, `--region region-code` tells AWS where the cluster is, `--name cluster-name` name to identify the cluster.

**what is kubeconfig ?**
- Kubeconfig is configuration file which tells `kubectl` where and how to connect to a Kubernetes cluster. By default it is `~/.kube/config`.
- **A kubeconfig allows you to keep information about multiple clusters and switch between them using contexts**.
- when we ran the command, AWS CLI gets the necessary information about `cluster-name` and adds it to our local i.e. in `~/.kube/config`.
- `~/.kube/config` -->  Cluster information, Authentication information & Context.
- kubeconfig is a configuration file that provides the necessary information to `kubectl` to connect to and Authenticate with Kubernetes cluster.

**What is context ?**
- Under Kuberenetes, Context is a configuration which tells kubectl whichkubernetes cluster and user credentials to use when executing commands.
- **Context = Cluster + User**
- when ran `kubectl get pods`, kubectl uses the current context to determine which cluster it should send the command to and which identity it should use.

**What is kubectl ?**
Kubectl is command line clint for kubernetes.
- It communicates with kubernetes API server. Through API server kubectl communicates with cluster
- the Flow:  User/Terminal --> Kubectl --> Kubernetes API server --> Kubernetes Control plane --> Cluster state --> Response --> Kubectl --> User/Terminal
- API server is the main entry point for kubernetes cluster

- Using the command `kubectl config use-context <context-name>`, select which cluster `kubectl` should talk to.   
  

- Now run `kubectl config view` --> o/p all the details of the EKS cluster.
- To check the current context, run `kubectl config current-context`
___

# Kubernetes

To deploy the project on kubernetes--

- Make sure all the requried **resources are created using Terraform.**
- Clone the repository **`ultimate-devops-project-demo`**(already done) to get the deploy.yaml files of the microservices and the **complete-deploy.yaml** file for the deployment.
- The file complete-deploy.yaml is available in kuberentes direstory. this consist of all the deployment and service resource in it and even the service account is created(for more info look into the file).
- Connect to the cluster that was created, How --> run `kubectl config current-context`, o/p --> should see the cluster that was created.
- Quick check if any pods containers are running / no previous deployments, How --> run `kubectl get all`
- Get to the path 'ultimate-devops-project-demo/kubernetes'.

# Service account creation:
What is Service account ? : **A service account is an identity for a pod inside Kubernetes**. It proivides identity to workloads running inside cluster.
kubectl --> Kubernetes API Server --> Create ServiceAccount --> opentelemetry-demo

Why Service account is needed ?  : **Pod needs an identity to determine who it is and what it is allowed to access, that identity is given by Service account. Service account is a Kubernetes identity for pods/applications, used to control what they are allowed to acces.**

- Need to create a service account `vim serviceaccount.yaml` check, and run `kubectl apply —f serviceaccount.yaml`, o/p --> 'serviceaccount/opentelemetry—demo created'. To varify run `kubectl get sa`. **The ServiceAccount now exists inside the Kubernetes cluster.** Note : If not created the Kubernetes will start using the default service account.
- Run `terraform apply -f complete-deploy.yaml`. This will start creating the services. list of created services and then deployments will be shown.
- To verify run `kubectl get pods`, make sure **all the pods** are in **running** state.
- To check services run `kubectl get svc`.
- Try accesing the frontend using the service Ip address:port, we were not able to access the project/frontend.
_____________
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
__________
## Give the controller permission

- Will start with checking the current cluster `kubectl config current-context`
- We need to create IAM role and assign policy with requried permissions to the IAM role.
- We will connect the service account with IAM role using IAM OIDC provider.
- **OIDC provider**: OIDC (OpenID Connect) Provider is a trusted identity provider that allows AWS IAM to verify the identity of a Kubernetes ServiceAccount. Kubernetes ServiceAccount --> OIDC --> AWS IAM --> IAM Role. Why we need oidc?, AWS does not have an way to trust Kubernetes identity. An OIDC provider **establishes trust between Kubernetes ServiceAccounts and AWS IAM**, enabling Pods to securely assume IAM roles.
- We need to configure the IAM OIDC provider, run `export cluster_name=<CLUSTER—NAME>`. We are Exporting/Storing the cluster name in `cluster_name` variable. 
- Command to extract the OIDC ID of the EKS cluster. `oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)`. The describe-cluster command gets information about the cluster, let's break down the command. `--query "cluster.identity.oidc.issuer"` extracts the OIDC issuer URL. `oidc_id=$(...)`, stores that value in the oidc_id variable.
- The OIDC ID will be saver in `oidc_id` variable, to check run `echo $oidc_id`. It will print the OIDC ID and can be verified.   
- Associates EKS cluster's oidc identity provider with AWS IAM  , run `eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve`. **It establishes the trust mechanism needed for Kubernetes Service account to use AWS IAM role.**
- **Kubernetes ServiceAccount --> OIDC --> AWS IAM**
- Need to create Service account and IAM policy, policy with ELB related permissions, create IAM role and attach that to the service account of ALB controller.
- **Download** the policy, AWS provides the policy in `.JSON` form. Run `curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json`
- The file will be found run `ls` and find `iam_policy.json` contains all the permissions related to elastic load balancer.
- To **Create IAM policy** run `aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json`. The policy will get created.
- Run `eksctl create iamserviceaccount --cluster=<your-cluster-name> --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::<your-aws-account-id>:policy/AWSLoadBalancerControllerIAMPolicy --approve`, this command **creates an IAM Service Account for Kubernetes and connects it to an AWS IAM Role**. This command gives the AWS Load Balancer Controller permission to manage AWS load balancers from inside the Kubernetes cluster without using AWS access keys. o/p will be --> serviceaccounts that exist in Kubernetes will be excluded, use —-override-existing-serviceaccounts to override.

______________

- **Install Helm** from using documentataion. This section is where we **actually install the AWS Load Balancer Controller into the EKS cluster**.
- **Your Helm --> AWS EKS Helm Repository --> AWS Load Balancer Controller chart**
- Helm is a package manager for Kubernetes. A Helm package is called Helm chart, A chart contains the Kubernetes configuration needed to deploy an application.
- Add helm repo related to EKS, run `helm repo add eks https://aws.github.io/eks-charts`. Adds the **AWS EKS Helm chart repository to your local Helm configuration**. Your Helm --> AWS EKS Helm Repository --> AWS Load Balancer Controller chart.
- Install the ALB controller `helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=<your-cluster-name> --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=<region> --set vpcId=<your-vpc-id>`. pass the parameters vpc-id, your-cluster-name and region. serviceAccount.create=false, because we already created the ServiceAccount and connected it to the IAM Role. It tells Helm to install the AWS Load Balancer Controller into my EKS cluster using the AWS Load Balancer Controller Helm chart. O/p --> AWS Load Balancer controller installed!.
- Verify the pods if up and running, run `kubectl get pods —n kube—system`. 
- Verify that the deployments are running, run `kubectl get deployment -n kube-system aws-load-balancer-controller`.

<img width="1536" height="1024" alt="ChatGPT Image Sep 2, 2026, 03_34_57 PM" src="https://github.com/user-attachments/assets/369cd74e-df0d-47c2-b335-ff0ce939745c" />

<img width="1536" height="1024" alt="Helm" src="https://github.com/user-attachments/assets/1f3ed32c-5279-40a3-9556-9fdc4177a365" />


_________

**Make sure the load balancer is removed --> run `kubectl edit svc opentelemetry—demo—frontendproxy` and change the type back to `type: NodePort`, the load balancer will be deleted automatically**

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

_______

Project Accessing -

- Once the status is `Active`, try running the **DNS name**, the project will not be accessible, it will fail. Cause, in the ingress.yaml file we have said only allow the access from `**example.com**`. As example.com is not a real domain, we need to edit DNS records of the system and then access the project.
- Run `nslookup DNS-name-given-by-loadbalancer`, try running the IPs and DNS names to access the project, it will FAIL. As mentioned only from example.com we can access the project.
- Will change the local DNS records of the local system in our case the VM for testing, run `sudo vim /etc/hosts`. Add the IP from nslookup command and example.com (Ex: 44.55.112.21 example.com) and save. (note: it might not work on some browsers, no need to worry)
- 😀😀 The project is successfully deployed using Ingress !!!!!!!!!!

___

# CICD

## CI with Github Actions:

Will be handling the CI with the help of Github Actions, reson to choose Github actions is that we are using GitHub as our version control paltform and will be easier to perform CI actions. 

- Get the **CI.yaml** prepared (the code explanation of CI.yaml is in /CICD/readme.md )
- ci.yaml has been added on `/deployment/ci.yaml`
- It consists of 4 jobs, namely `build, code-quality, docker and updatek8s`.
- Once the docker job is completed in the last step i.e. `updatek8s` the updated k8s manifest will be pushed to the github, where CD will taked over the deployment according the updated k8s manifests.  

[We are performing the CI for a microservice **product catalog** for understanding the CI actions and to understand the structure of CI.yaml (jobs and steps are explained in that file.)]

- Place the **CI.yaml** file in `.github/workflows` directory in the repo.
- Get to the terminal and create a change and push it. run `git checkout —b githubcicheck`
- Push a change, go to main.go and add a comment(to create a change).
- Check it, run `git status`. o/p --> 'modified:   src/product-catalog/main .go' in red.
- Run `git add .` and run `git commit -am "chore: verify github actions"`.
- Run `git push origin githubcicheck`. the url for the pull request will be recived as o/p.
- Browse the url, it might ask pull request to opentelemetry main repo, change it to the forked one under in our account. Now create the pull request, click `Create pull request`
- Now we see github actions under action --> running the jobs build, code quality, docker and updatek8s as we defined in CI.yaml file, with each setp performed and progress will be shown on the github UI.
- Docker job will triger if the build completes successfully and updatek8s runs if the docker job is successful. (As we mentioned needs: build under docker and needs: docker under updatek8s)
[there might be some unused variables or unused functions proving the static code analysis under code-quality, and might fail.]
- Once all jobs are completed, we can check the kubernetes manifest to check the updated docker image as we have coded under updatek8s job. check 'ultimate-devops-project-demo / kubernetes / productcatalog / deploy.yaml' under this `image:` with new image name. We can cross check with dockerhub tag in deploy.yaml file.
- As the last stage got passed, the pull request and branch will be closed.
- If updatesk8s has to triger only if all the previous jobs are successful, just change `needs: docker` to `needs: [build, code-quality, docker]`. Only if all the previous jobs are successful, then only the changes will be pushed to github from `updatek8s` job.

- CI is Done !!!

CI Code explination is given under /CICD/readme.md
_________

## CD with GitOps

**Installation and Setup**
- Run `kubectl create namespace argocd`, We are creating a namespace called **argocd **.
- Run `kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`
- Check the installation, run `kubectl get pods -n argocd`, and wait until all the pods are in running state.
- Run `kubectl get svc -n argocd`, will get the list of different services of argocd, we need 'argocd-server'
- Run `kubectl edit svc argocd-server -n argocd`, now change the `type: ClusterlP` to `type: LoadBa1ancer`. O/p --> 'service/argocd—server edited'
- Run `kubectl get svc -n argocd`, get the `EXTERNAL-IP`. It will take some time to get the LoadBalancer up.
- Once the ArgoCD UI is accessible, We will then proceed with configuring it with the git repository and automatically deploying the new version to K8s cluster. (click on `advanced` and then on `accept the risk and continue` button.)
- To login once the UI is up on screen, run `kubectlget secrets -n argocd`, and run `kubectl edit secret argocd—initial-admin—secret —n argocd`, copy the password and exit the file.
- Run `echo 'password-that-was-copied' | base64 --decode`, now copy the actual password from the output.
- Now login to argocd, username = admin and password = the new password from the o/p.
[Note: Using one Argo CD, we can deploy the change to multiple clusters.]

**Configuring ArgoCD with GitHub**
- Now the Login is done, click on `Create Application` button.
- Provide a name for the application (like 'product-catalog'), keep project name as 'default', sync policy  (Automatic : Argo CD will automatically detect any changes in the git repo and deploys that to the cluster. For every 180 sec the ArgoCD will detect the changes and deploy.), check the box of 'SELF HEAL'. Under 'Source' provide the repo's URL. 'Revision' will be 'HEAD'. Under 'PATH' provide 'kubernetes/productcatalog'. 'Cluster URL' will be 'https://kubernetes.default.svc'. 'Namespace' will be 'default'. 
- Click on the `CREATE` button on the top.
- Let the process run, now check if the latest deployment is done. Click on the pod that is up, under SUMMARY >> IMAGES, we get to see new name of the new image, updated by CI and now being deployed.  
- Can push a new change in product catalog's main.go code (like a comment) and see CI CD in action, once the change is pushed.

------------------------------x------------------------------
