

terraform {
  backend "s3" {
    bucket         = "my-terraform-demo-state-bucket"   
    key            = "projects/webapp/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"             
  }
}
