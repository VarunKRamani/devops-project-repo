# Terraform Learnings 

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
Locking with AWS S3 and DynamoDB

Where S3 is for remote storage and DynamoDB table used for state locking

Process -- For storing the statefile in remote backend for which we will be using S3 and will be using DynamoDB table for state locking.
Will be writing a .tf file to create S3 and dynamoDB -- bellow is the explination and the fill written in VScode will is uploded in the _/Terraform_  

1. Start from provider block, in our case its AWS
2. Next resource block, tell aws what resources need to be created.
3. A Variables file to pass veriables to the resource block.
4. Then we can create output.tf to see the output if needed.

make use of terraform aws provider documentation-- for code samples

# Writing a terraform file (Explination)
teraform file (.tf) for creating S3 and DynamoDB 
-
**1. Starting with the Provider Block**
```sh
provider "aws" {
  region     = "us-west-2"
}
```
what it does,
- Tells terraform which cloud procider to use i.e. AWS
- specifies in what region to create the resource i.e. us-west-2 (all the resources created will be in this region)

**2. Resource block of S3 Bucket**
```sh
resource "aws_s3_bucket" "terraform_state" {
  bucket = "demo-terraform-eks-state-s3-bucket"

  lifecycle {
    prevent_destroy = false
  }
}
```
what it does,
- Creates an S3 bucket to store our terraform statefile
- lifecyce block - terraform can delete this bucket if destroyes. If `true` then it would refuse deletion.

**3. Resource blockk of bucket versioning**
```sh
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
```
what it does,
- It enables versioning on the S3 bucket
- Terraform state is very sensitive so it would be easy to recover old state if corrupted or rollback mistakes, track changes and protect accidental deletion

**4. Resource block of Server-side Encryption**
```sh
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```
what it does,
- Encrypts the ststefile automatically when stored
- It is AWS-managed encryption

**5. Resource block of DynamoDB table for State Locking**
```sh
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-eks-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```
what it does,
- Creates a DynamoDB table used for terraform state locking
- when terraformm runs it creates a lock record, other users must wait until the lock is released.
- `PAY_PER_REQUEST` - pay only when used, no capacity planninf requried.
- `LockID` - primary key used to store lock entries (string type)

# **What this file achieves and Workflow**

Step 0. The infrastructure is created, i.e. S3 is storing state, DynamoDB table handles locks and Encryption and versioning are enabled.

Step 1. We run `terraform apply`, terraform starts the execution.
    
Step 2. Terraform check if the lock(DynamoDB) already exist, if no lock then it creates a lock entry and lock record stored with `LockiID`

Step 3. Terraform Download current state (S3), terraform fetches the latest state file from Amazon S3.

Step 4. Terraform creates execution plan, terraform compares the desired configuration and current state of the infrastructure. Then decides to create/modify/delete/do nothing.

Step 5. Infrastructure Changes Execut, terraform now creates AWS resources, modifies existing resources or deletes unnecessary resources. 

Step 6. Updates the State and Saves to S3, terraform updates the statefile and uploads the new version to S3 (Cause versioning is enabled the old version is preserved).

Step 7. Lock Released, terraform deletes lock record from DynamoDB (Now other user can run `terraform apply`).

**The file S3dynamo.tf is added in /Terraform.**
