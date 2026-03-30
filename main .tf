# ============================================================
# main.tf
# All infrastructure resources in logical dependency order:
#   1. VPC
#   2. Subnets
#   3. Internet Gateway
#   4. Route Table + Associations
#   5. Security Group
#   6. S3 Bucket
#   7. EC2 Instances
#   8. ALB + Target Group + Attachments + Listener
# ============================================================


# -----------------------------------------------------------
# 1. VPC
# -----------------------------------------------------------
resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "my-vpc"
  }
}


# -----------------------------------------------------------
# 2. Subnets
# -----------------------------------------------------------
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.subnet1_cidr
  availability_zone       = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.subnet2_cidr
  availability_zone       = var.az2
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}


# -----------------------------------------------------------
# 3. Internet Gateway
# -----------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "my-igw"
  }
}


# -----------------------------------------------------------
# 4. Route Table & Subnet Associations
# -----------------------------------------------------------
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}


# -----------------------------------------------------------
# 5. Security Group (HTTP + SSH inbound, all outbound)
# -----------------------------------------------------------
resource "aws_security_group" "webSg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}


# -----------------------------------------------------------
# 6. S3 Bucket (for project assets)
# -----------------------------------------------------------
resource "aws_s3_bucket" "example" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "project-assets-bucket"
  }
}


# -----------------------------------------------------------
# 7. EC2 Instances (one per subnet / AZ)
# -----------------------------------------------------------
resource "aws_instance" "webserver1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sub1.id
  vpc_security_group_ids = [aws_security_group.webSg.id]
  user_data              = base64encode(file("userdata.sh"))

  tags = {
    Name = "WebServer-1"
  }
}

resource "aws_instance" "webserver2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sub2.id
  vpc_security_group_ids = [aws_security_group.webSg.id]
  user_data              = base64encode(file("userdata1.sh"))

  tags = {
    Name = "WebServer-2"
  }
}


# -----------------------------------------------------------
# 8. Application Load Balancer
# -----------------------------------------------------------
resource "aws_lb" "myalb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webSg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "my-alb"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = var.tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }

  tags = {
    Name = "my-target-group"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
