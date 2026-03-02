#Provider and resources for S3 bucket and DynamoDB table for Terraform state management

provider "aws" {
  region     = "us-west-2"
}

#Resource for S3 bucket to store Terraform state files
#prevent_destroy is set to false to allow the bucket to be destroyed when the Terraform configuration is destroyed. This is useful for testing and development purposes.
#In a production environment, it is recommended to set prevent_destroy to true to prevent accidental deletion of the bucket and loss of state files.

resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "terraform-state-bucket-for-demo-"
  
  lifecycle {
    prevent_destroy = false
  }
}

# Can also add rendomise a part of the name, with a resource block and using `${random_id.suffix.hex}` with bucket name.

#Ewnable versioning for the S3 bucket to keep track of changes to the state files

resource "aws_s3_bucket_versioning" "terraform_bucket" {
  bucket = aws_s3_bucket.terraform_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#Resource for server-side encryption configuration for the S3 bucket to ensure that the state files are encrypted at rest
#sse_algorithm is set to AES256, which is a strong encryption algorithm that provides a high level of security for the state files.

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_bucket" {
  bucket = aws_s3_bucket.terraform_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#Resource for DynamoDB table to be used as a state lock for Terraform to prevent concurrent modifications to the state files
#The table is configured with a hash key named "LockID" of type string (S) and uses the PAY_PER_REQUEST billing mode, which allows for on-demand capacity without the need to provision read/write capacity units. 
#This setup is ideal for Terraform state locking, as it ensures that locks are created and released efficiently without incurring unnecessary costs.

resource "aws_dynamodb_table" "terraform_table" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
  

}
