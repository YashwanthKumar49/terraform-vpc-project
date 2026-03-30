# ============================================================
# outputs.tf
# Exposes useful resource attributes after apply.
# ============================================================

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer — use this URL to access the app"
  value       = aws_lb.myalb.dns_name
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.myvpc.id
}

output "subnet1_id" {
  description = "ID of public subnet 1 (ap-south-1a)"
  value       = aws_subnet.sub1.id
}

output "subnet2_id" {
  description = "ID of public subnet 2 (ap-south-1b)"
  value       = aws_subnet.sub2.id
}

output "webserver1_instance_id" {
  description = "Instance ID of WebServer 1"
  value       = aws_instance.webserver1.id
}

output "webserver2_instance_id" {
  description = "Instance ID of WebServer 2"
  value       = aws_instance.webserver2.id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket created for project assets"
  value       = aws_s3_bucket.example.bucket
}
