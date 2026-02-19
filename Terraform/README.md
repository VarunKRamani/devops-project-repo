# Terraformm Learnings 

**Terraform**: 
- A tool, an Infrastructure as Code (IaC) tool used to **create, manage, and automate** cloud infrastructure using code instead of manual way of setting things up using GUI of the cloud platform. Mainly used to manage and automate infrastructure. 
this tool is from By HashiCorp.

As we know it's compatible with all the cloud platforms, which makes it useful in Hybrid cloud cases. 

Terraform lifecycle: terraform init, terraform plan & terraform apply

- `terraform init` - as the name suggest it initalises the project, it _setups the requried terraform environment_ beform creating infrastructure.
- `terraform plan` - nothing but a _dry run_, reads the _.tf_ configuration and shows the execution plan, it shows what terraform will create, update, or delete.
- `terraform apply` - this is where the actual _API calls are made_ and the infrastructure wil be **_created_**. Even the **statefile** will be read in this process on which the changes/modifications will be done in the infrastructure.
Statefile will be further discussed.

**_WRT this Project_** - Terraform needs to create resources on AWS. So, for terraform to make AIP calls we need to authenticate with AWS(user credentials and IAM user credentials), explained in below steps:
1. Login with IAM user(Create Access key)
2. Install AWS CLI on the virtual machine
3. Configure aws using `AWS Configure` with access key and secret access key.
4. run `ls ~/.aws/c` to find credentials file and confirm the configuration.
note: This credentilas file has the info of access key and secret access key, when we run terraform plan or terraform apply, the terrafoem will read the credentials file and apply the configuration on AWS


**Terraform StateFile**:
Statefile is the only source of truth terrafoem uses to manage real infrastructure.
Terrafrom remembers actions and it updates this statefile after each action.

terraform statefile --------(is)--------> the current state of the Ingrastructure.

It only stores the current snapshot of the infrastructure. It acts as terraform's memory, based on which the actions are performed. 

What it records?  --> It recodrs the infomation like resource details, resource ids, meta data and mapping configuration.

Why it records?  --> without statefile, terraform would have no memeory of what resources were created, terraform knows what exactly has been created, updated or deleted. whithout it terraform would loose the track of the infrastructure and would be impossible to apply changes safely or avoide duplication in future runs.

**Statefile Management**

Terraform statefile management is important, cause statefile it lets terraform keep track of all the real world resources. It ensures that the statefile is updated after each action performed by terraform.

when the terraform runs initally the statefile is created locally. This is fine until when working solo or on personal project. 
In larger projects where multiple people need to collabrate we would rist loosing statefile in sync. The walkaround is to move the statefile to remote backend.

**Remote Bancked**
A Storage location where the statefile is stored outside the local machine, so multiple users can share and manage infrastructure.
It centralizes the statefile and enables versioning and backup.
Ex: AWS S3, terraform cloud etc

As we store the statefile in remote backend its also important to have set permissions or a lock machanism that prevents multiple people or processes from changing the state at the same time.

**State Locking**
State locking is a mechanism that prevents multiple people or processes from changing the terraform state at the same time. 

How it works? --> when a process whats to make an update, it places a lock on the statefile, in remote backend, so on one else can apply changes until the lock is released. 
results in avoiding of coonflits, duplication an ensures only one changes is made at a time, keeing the infrastructure consistent.

Process -- For storing the statefile in remote backend for which we will be using S3 and will be using DynamoDB table for state locking.

1.
