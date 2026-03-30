# ============================================================
# variables.tf
# Declares ALL input variables used across the project.
# Default values act as fallbacks; tfvars takes precedence.
# ============================================================

variable "aws_region" {
  description = "AWS region where all resources will be deployed"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "subnet1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "192.168.1.0/24"
}

variable "subnet2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "192.168.2.0/24"
}

variable "az1" {
  description = "Availability Zone for subnet 1"
  type        = string
  default     = "ap-south-1a"
}

variable "az2" {
  description = "Availability Zone for subnet 2"
  type        = string
  default     = "ap-south-1b"
}

variable "ami_id" {
  description = "AMI ID for both EC2 web server instances"
  type        = string
  default     = "ami-02b8269d5e85954ef"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for the project assets"
  type        = string
  default     = "terraform-s3-test-reya-project"
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "myalb"
}

variable "tg_name" {
  description = "Name of the ALB Target Group"
  type        = string
  default     = "myTG"
}
