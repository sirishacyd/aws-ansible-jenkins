provider "aws" {
  region = "us-east-2" # Change this to your desired AWS region
}

# Create an EC2 instance
resource "aws_instance" "my_instance" {
  count = 1

  ami                    = "ami" # Specify the AMI ID for your desired Amazon Machine Image
  instance_type          = "t2.medium"
  key_name               = "key-name" # Change this to your key pair name
  vpc_security_group_ids = [aws_security_group.terraform-instance-sg.id]

  tags = {
    Name = "CI-CD"
  }
}

output "jenkins_public_ip" {
  value = [for instance in aws_instance.my_instance : instance.public_ip]
}

# Create a security group
resource "aws_security_group" "terraform-instance-sg" {
  name        = "terraform-created-sg"
  description = "Allow inbound ports 22, 8080"
  vpc_id      = "vpc-id" # add VPC ID

  # Allow incoming TCP requests on port 22 from any IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming TCP requests on port 443 from any IP
  ingress {
    description = "Allow HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming TCP requests on port 80 from any IP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming TCP requests on port 8080 from any IP
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
