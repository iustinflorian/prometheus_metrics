provider "aws" {
  region = "eu-north-1"
}

resource "aws_security_group" "prometheus_sg" {
  name        = "prometheus_sg"
  description = "Allow monitoring traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
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

resource "aws_instance" "prometheus_server" {
  ami           = "ami-0faab6bdbac9486fb"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.prometheus_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io docker-compose
              sudo systemctl start docker
              sudo systemctl enable docker
              EOF

  tags = {
    Name = "Prometheus-Server"
  }
}

output "server_ip" {
  value = aws_instance.prometheus_server.public_ip
}