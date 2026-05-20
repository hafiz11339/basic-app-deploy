data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "app_sg" {
  name = "${var.app_name}-sg"

  # Allow FastAPI port
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH (for debugging)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # This script runs on first boot — installs Docker and starts your app
  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker

    # Pull and run your app from GitHub Container Registry
    docker pull ghcr.io/${var.github_username}/${var.app_name}:latest
    docker run -d -p 8000:8000 --restart always ghcr.io/${var.github_username}/${var.app_name}:latest
  EOF
  )

  tags = {
    Name = var.app_name
  }
}