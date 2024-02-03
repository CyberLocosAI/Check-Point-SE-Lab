
data "aws_ami" "check_point" {
  most_recent = true
  owners      = ["679593333241"]  # Check Point's AWS account ID

  filter {
    name   = "name"
    values = ["*Check Point CloudGuard IaaS BYOL R81*" ]
  }
}

resource "aws_security_group" "instance_sg" {
  count = 5  # Assuming 5 VPCs

  name        = "instance-sg-${count.index}"
  description = "Security group for EC2 instance in VPC"
  vpc_id      = aws_vpc.main[count.index].id  # Reference the VPC ID from your existing configuration

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH Ingress
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTPS Ingress
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

resource "aws_instance" "vpc_instance" {
  count = 5  # Assuming 5 external subnets

  ami           = data.aws_ami.check_point.id
  instance_type = "m5.xlarge"
  subnet_id     = aws_subnet.external[count.index].id

  vpc_security_group_ids = [aws_security_group.instance_sg[count.index].id]
  key_name               = "fllabmainkey"  # Ensure this key exists in your AWS account

  tags = {
    Name = "CP-Manager-${count.index}"
  }
}
