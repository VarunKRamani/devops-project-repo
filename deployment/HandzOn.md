# Hands on with the Project

## Setting the Budget -
- Insted of using EC2 from AWS to build infrastructure and access clusters etc, a virtualbox ubuntu VM was used to keep the cost low.
- The project has been set with the budget. This is set keeping in mind of things including project architecture built using terraform, kuberneres clusters and CICD. 
<img width="700" height="400" alt="Screenshot 2026-04-15 132103" src="https://github.com/user-attachments/assets/01781d08-deae-4ca8-a114-a4bd6cd6689e" />

- The Alerts have been set, basing on the resource usage the cost will climb and will be notified if corsses the set limit. 
<img width="800" height="250" alt="Screenshot 2026-04-15 132519" src="https://github.com/user-attachments/assets/5a0ccc95-4072-4498-b9c3-da75b59272ac" />

____
**Prerequisites for the deployment--**
- Base Environment --> Ubuntu VM (VirtualBox) or Linux system
- Installed tools: AWS CLI, Terraform, Kubectl, Docker, eksctl, helm, AWS Configuration - `aws configure`.
____
## Creation of S3 and DynamoDB for State Locking -
- Backend configuration wrt terraform, Creation of S3 and DynamoDB.
- The S3 bucker name has been updated wrt to the terraform file and it's 'demo-terraform-aws-varu-eks-state-s3-bucket'
- And the Table name is 'terraform-eks-state-locks'.
- The resouce are created in **(Oregon) us-west-2** region.

<img width="800" height="600" alt="Screenshot 2026-04-15 144215" src="https://github.com/user-attachments/assets/263a7b98-f096-4bd5-b1de-c399487295fa" />

<img width="800" height="600" alt="image" src="https://github.com/user-attachments/assets/afb9ee1e-59fb-4698-ac2a-1285c1459fb1"/>

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

- Run `aws eks update-kubeconfig --region us-west-2 --name cluster_name`, o/p --> 'Added new context ___-'
- Check if connect to EKS cluster, run `kubectl config current-context`, o/p --> 'displays the cluster name'

<img width="800" height="600" alt="Screenshot 2026-05-08 113436" src="https://github.com/user-attachments/assets/89539838-4435-4344-a2da-07751ae40389" />

- Get into to the directory '~/ultimate-devops-project-demo/kubernetes'.
- Create a Service account,there is a .yaml file. Run `kubectl apply -f serviceaccount.yaml`, o/p --> 'serviceaccount/opentelemetry-demo created'

<img width="800" height="600" alt="Screenshot 2026-05-08 113653" src="https://github.com/user-attachments/assets/254ac782-fc7b-4768-8a09-45e59544883c" />

<img width="800" height="600" alt="Screenshot 2026-05-08 113901" src="https://github.com/user-attachments/assets/7d3ffc4e-77a0-4c75-b791-aeee7fa736ff" />

- To check, run `kubectl get sa`, o/p --> table with default service account and the created service account 'opentelemetry-demo' with AGE will be displayed.

<img width="800" height="600" alt="Screenshot 2026-05-08 113942" src="https://github.com/user-attachments/assets/aab88eb4-650a-4463-aa3f-1012e36f169c" />

- Now, run the 'complete-deploy.yaml' file to up all the services, run `kubectl apply -f complete-deploy.yaml`. The services will start getting created then deployments.

<img width="800" height="600" alt="Screenshot 2026-05-08 114143" src="https://github.com/user-attachments/assets/3f95e62c-09f9-4c20-a75c-42271b64558a" />

<img width="800" height="600" alt="Screenshot 2026-05-08 114128" src="https://github.com/user-attachments/assets/4366dba2-4218-4707-99c7-b3414f5c11c7" />

- To check, run `kubectl get pods`. **Wait until the status of all the pods come to 'Running'.**

<img width="800" height="600" alt="Screenshot 2026-05-08 114239" src="https://github.com/user-attachments/assets/432a4c36-ad31-45e5-982c-b3cb65f3387b" />

- Check the same for services, run `kubectl get svc`. With the type 'ClusterIP'. Can use `kubectl get all` to list both services and pods.

<img width="800" height="600" alt="Screenshot 2026-05-08 114356" src="https://github.com/user-attachments/assets/47cf6eaa-f5c7-417d-a54b-ad7b836526e0" />

## Accessing the project 
- To Access FrontEnd, we need to change the service type of the frontendproxy, run `kubectl get svc | grep frontendproxy`.
- Run `kubectl edit svc opentelemetry-demo-frontendproxy`, change the type to `LoadBalancer`. **save and Wait for 5-10 min atleast.**
- Check the AWS console if the Load Balancer is created, and get the DNS once created. or copy idt from the terminal, for that run `kubectl get svc opentelemetry-demo-frontendproxy`. The port is `8080`.
- Browse `DNS:port`, Will be able to access the frontend.
🎉😃🥳

**NOTE : - Change the service type of frontendProxy back to 'Nodeport'. Run `kubectl edit svc opentelemetry-demo-frontendproxy` in it change the type to `NodePort`.** and loadbalancer = money. 

## Ingress **

- Quick check, run `kubectl config current-context`.

- Export the cluster name, run `export cluster_name=my-eks-cluster`

- Fetch the OIDC Id, run `oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | '/' -f 5)`

- Now run `echo $oidc_id`. O/p --> oids id.

<img width="800" height="600" alt="Screenshot 2026-05-08 115731" src="https://github.com/user-attachments/assets/3ffc7e2d-97f5-48db-a48c-a52ca6e0a0c2" />

- Now we will associate IAM oidc provider with the cluster(adding oidc provider to the cluster), run `eksctl utils associate-iam-oid-provider --cluster $cluster_name --approve`

<img width="800" height="600" alt="Screenshot 2026-05-08 120634" src="https://github.com/user-attachments/assets/21525b4c-3596-4e6d-a97f-3b568da45bda" />

- Download the `iam_policy.json`, run `curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/instal/iam_policy.json`.

<img width="800" height="600" alt="Screenshot 2026-05-08 121251" src="https://github.com/user-attachments/assets/25739a8d-14a5-43d6-bdbf-37c58553dcb7" />

- Create the policy, run `aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json`.

<img width="800" height="600" alt="Screenshot 2026-05-08 121251" src="https://github.com/user-attachments/assets/da541f9a-6fc7-4432-94ba-67e8b4123bf6" />

- Assign IAM role to the service account, run `eksctl create iamserviceaccount \
--cluster=<your-cluster-name> \
--namespace=kube—system \
--name=aws-load-balancer-controller \
--role-name AmazonEKSLoadBalncerControllerRole \
--attach-policy-arn=arn:aws:iam::<your-aws-account-id>:policy/AWSLoadBalancerControllerIAMPolicy \
--approve`. Provide the AWS ID and Cluster name.

_____
- Install helm.
<img width="800" height="600" alt="Screenshot 2026-05-08 122829" src="https://github.com/user-attachments/assets/1a079cf7-7a0b-4042-83d5-0e96f8346ea4" />

- Run `helm repo add eks https://aws.github.io/eks-charts`.

<img width="800" height="600" alt="Screenshot 2026-05-08 123056" src="https://github.com/user-attachments/assets/2bccab9c-80fb-4b17-ae53-66d77ce9064c" />

- To install ALB Controller, run `helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
-n kube-system \
--set clusterName=<your-cluster-name> \
--set serviceAccount.create=fa1se \
--set serviceAccount.name=aws-load-ba1ancer—contr011er \
--set region=<region> \
--set vpcId=<your-vpc-id>`.
Provide Cluster name, VPC id and Region. o/p --> AWS Load Balancer controller installed!

<img width="800" height="600" alt="Screenshot 2026-05-08 125212" src="https://github.com/user-attachments/assets/ff18a302-b8bc-4b19-81ac-95818f8ab68e" />

- Verify if the ALB pods are up and running, run `kubectl get pods -n kube-system`. The formed pords(2) should be in 'Running' state/status.

<img width="800" height="600" alt="Screenshot 2026-05-08 125254" src="https://github.com/user-attachments/assets/e00a4494-8d1a-4a22-8257-51ef932cbf84" />

- Can check the logs to further verify, run `kubectl logs <pod name> -n kube-system`. No error -> ALB controller installation is successful.
____
**Ingress resource creation--**
- Change the service type of frontendProxy back to 'Nodeport'. Run `kubectl edit svc opentelemetry-demo-frontendproxy` in it change the type to `NodePort`. **Done after accesing the project.** The loadbalancer once the service type is changed will get deleted automatically.

- Get into directory `~/ultimate-devops-project-demo/kubernetes/frontendproxy$`. Create ingress.yaml file.

- Run, `kubectl apply -f ingress.yaml`. o/p --> 'ingress.networking.k8s.io/frontend—proxy created'

- Run, `kubectl get ing`, o/p --> ingress details. Check AWS console if the LB is created and the status be 'Active'.

<img width="800" height="600" alt="Screenshot 2026-05-08 130912" src="https://github.com/user-attachments/assets/cd85aa5c-14a7-4312-aedb-ced1f7b863ce" />

- As the `host` in ingress file is set as 'example.com', by browsing the ip or the DNS we cannot access the project. So, we will set the ip to the domain within out locak DNS records.

- Get the Ip by running, `nslookup <dns-name-from-loadbalancer>`. In the local machine run `sudo vim /etc/hosts`, where we will write a dns record `IpAdress example.com` and save.

<img width="800" height="600" alt="Screenshot 2026-05-08 132110" src="https://github.com/user-attachments/assets/dec660b1-ba92-4100-930a-532ab874386a" />

- Now browse 'example.com' and will be able to access the frontend.

<img width="800" height="600" alt="Screenshot 2026-05-08 132333" src="https://github.com/user-attachments/assets/5a30522d-930a-411f-a9c9-51ea7753060d" />

<img width="800" height="600" alt="Screenshot 2026-05-08 132428" src="https://github.com/user-attachments/assets/5151c8fc-e936-4d82-a834-d5ebc7fff5d0" />

🎉😃🥳😃
_____

**Second deployment was made with Intigration of CICD, CI with GitHub Action and CD with GitOps(ArgoCD)**

## CICD
GitHub Actions used for **CI**, Implementing CI for a microservice.
- Once the directory and ci.yaml file is created. The exp of ci.yaml is in /CICD/Readme.md
- Started by creating repo's Actions secrets. **New Repository Secret** , Add `DOCKER_USERNAME` and `DOCKER_TOKEN`.
<img width="750" height="500" alt="image" src="https://github.com/user-attachments/assets/bc4ae610-a08a-42ba-aa95-8759e9c7fb5f" />

- Create the Github token and add that token to the secrets of the repo. `GITHUB_TOKEN`
<img width="750" height="250" alt="image" src="https://github.com/user-attachments/assets/53204051-ea5f-41d2-b510-5d3dca346387" />

- Create a branch, run `git checkout -b githubcicheck`. o/p --> Switched to a new branch 'githubcicheck'.
- We will create a change in the code i.e. in '/src/product-catalog/main.go' like add a comment.
- Check the change, run `git status`.
-  Add, run `git add.`. Commit, run `git commit -am "chore: verify github actions"`
-  Push the changes, run `git push origin githubcicheck`. get the **url** generated for pull request, browse it pull it on the out repo and create a pull request.
-  Now we see 4 jobs as we created namely - build, codeQuality, docker and updatek8s.
-  Updatek8s is the bridge between CI and ArgoCD. 
-  Takes the newly built Docker image tag and update the Kubernetes deployment manifest in Git so that ArgoCD can deploy the new version automatically.
-  Once all the 4 jobs are done, the pull request is closed.

-------------------------------------------------------------------------------------
# CD with GitOps

Once the kubernetes manifest is updated by CI, CD starts from updated kubernetes manifest.

GitOps is an approach where the kubernetes manifest, which got updated by the CI stage, is stored in a version control system like git. The CD platform like Argo CD will read these changes and deploy them onto target platform like kubernetes.

- Git as version control system and deploying them on kubernetes cluster.
- Constant monitoring of the version control system to verify if there is a new image, and once there is a new image, this will automatically deploy to the cluster.
- Reconciliation of state. That is, if something is modified on kubernetes cluster, now Argo CD or GitOps immediately looks at this change and overrides that to the previous state because, in the concept of GitOps, **version control system is the source of truth**.
- Any manual changes onto the cluster or anything changing abruptly. The state maintained by Argo will again deploy the existing version from version control system.

- Create a name space called `argocd`, run `kubectl create namespace argocd`. o/p --> namespace/argocd created.
- Run the .yaml file provided by argocd, run `https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`.
- Run `kubectl get pods -n argocd`. List of pods and let be in running state.
- Run `kubectl get svc -n argocd`. Take a look at `argocd-server` which hosts the UI of ArgoCD.
- Run `kubectl edit svc argocd-server -n argocd`. Change the type to loadbalancer `type: LoadBalancer` and save it. o/p --> service/argocd—server edited.
- Run `kubectl get svc -n argocd`. Check if the loadbalancer service type is created. (Wait for few min until the service is created)
- Once the ArgoCD UI is accessible. Login to it, run `kubectl get secrets -n argocd` and run `kubectl edit secret argocd—initial—admin—secret —n argocd` to get the password, copy the `password`.
- It is 64 bace N coded, run `echo password | base64 --decode`, the actual password will be displayed.
- Now login to ArgoCD, username : admin and password : the displayed password.
____
- Click on `CREATE APPLICATION`, provide `Application Name` like 'productcatalog-service'.
- `Project Name` will be 'default'. `SYNC POLICY` will be set to 'Automatic' (Meaning: Argo CD will automatically detect any changes in the git repo) and check `SELF HEAL` box.
- Provide the `Repository URL` from github. `REVISION` will remain 'HEAD'. `Path` will be 'Kubernates/productcatalog'.
- Under `DESTINATION`, `Cluster URl` will be 'https://kubernetes.default.svc' and `Namespace` will be 'default'.
- Click on `Create` button.
- Run `kubectl get rs` new replica set will be delpoyed by ArgoCD, `opentelemetry-demo-productcatalogservice-xxxx123456` replica set.
- Run `kubectl edit rs opentelemetry-demo-productcatalogservice-xxxx123456`, check if new image is deployed.


**The first deployment was purely done to access the project 
the 2nd deployemnt was made where CI and CD was implemented and tested with changes. 
**

Second deployment results :

-------------------

