# Declare the variable to hold the AMI ID
variable "AWS_AMI_CP_MANAGER" {
  description = "AMI ID for the Check Point Manager"
  type        = string
  # You can provide a default value or leave this empty
}

# Security group for EC2 instances in each VPC
resource "aws_security_group" "instance_sg" {
  count = 5  # Assuming 5 VPCs

  name        = "instance-sg-${count.index}"
  description = "Security group for EC2 instance in VPC"
  vpc_id      = aws_vpc.main[count.index].id  # Reference the VPC ID from your existing configuration

  # SSH Ingress
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS Ingress
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Deploying an instance in each external subnet
resource "aws_instance" "vpc_instance" {
  count = 5  # Assuming 5 external subnets

  ami           = var.AWS_AMI_CP_MANAGER
  instance_type = "m5.xlarge"
  subnet_id     = aws_subnet.external[count.index].id

  vpc_security_group_ids = [aws_security_group.instance_sg[count.index].id]
  key_name               = "fllabmainkey" # Make sure this key exists in your AWS account

  tags = {
    Name = "Instance-VPC-${count.index}"
  }
}