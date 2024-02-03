data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  // Canonical's AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_security_group" "ubuntu_sg" {
  count = length(aws_subnet.external.*.id)

  name        = "ubuntu-sg-${count.index}"
  description = "Security group for Ubuntu instances"
  vpc_id      = aws_subnet.external[count.index].vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  // Allows SSH from any IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  // Allows all outbound traffic
  }

  tags = {
    Name = "Ubuntu-SG-${count.index}"
  }
}

resource "aws_instance" "ubuntu_server" {
  count = length(aws_subnet.external.*.id)

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.external[count.index].id
  key_name      = "fllabmainkey"  // Name of your existing key pair
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ubuntu_sg[count.index].id]

  tags = {
    Name = "Ubuntu-Server-${count.index}"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Initialization script here
              EOF
}
