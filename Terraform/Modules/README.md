# Modular Approach of writing a terraform file 

The Modular apporach in terrafoem menas breaking the infrastructure code in bits of resubale modules/components insted of writing everything in one big file.

It is like a function, i.e. write once use many times.

## **Why Modules ?**
1. **Reusability** --> Once written Modules can be reused across miltiple projects. Example: A VPC module can be used for different environments (dev, staging, production) without rewriting the VPC configuration every time.

2. **Easy Maintenance** --> Simplifies Management by keeping infrastructure code organized. Example: An EKS module can be managed, updated, and versioned separately without affecting other resources.

3. **Team collabration** --> Different teams can work on different modules independently. Example: The networking team can manage the VPC module, while the DevOps team configures the EKS module.

4. Scalabil****ity --> Esaier to scale the infrastructure as the modules allow independent provisioning. Example: Scaling an EKS cluster without modifying the entire Terraform configuration.

## **How Terrafoem Modules Work?**
1. Create a Module -- A module is a folder with terrafoem files (main.tf, output.tf, variables.tf). It contains reusable infrastructure code like VPC, S3 or EC2

2. Define input Variables -- Modules define variables to accept values from users.

3. Call the module -- The main terraform file calls the module using a `module` block.

4. Terraform creates Resources -- When `terraforom apply` is run, it executes the module code.

5. Module return output -- Modules can return values like resource IDs or endpoints. The output can be used by other modulesor configurations.

## Variables and how it works.
In terraform, a Variable is defined using a variable block.
To access the variable use `var.variable_name`\

Basic syntax :

``` hcl
variable "variable_name"{
  descriptin = "what this variable does"
  type       = string
  default    = "value"
}
```
Examples :
-  **variables.tf**
```hcl
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}
```
**main.tf**
```hcl
provider "aws" {
  region = var.region  
}
```
-  **Variables.tf**
```hcl
variable "instance_count" {
  discription = "Number od EC2 instances"
  type        = number
  default     = 2
}
```
**main.tf**
```hcl
resource "aws_instance" "example" {
  count = var.instance_count
}
```
