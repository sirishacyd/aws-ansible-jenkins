# Efficient AWS Infrastructure Management

## Introduction
Ansible and Jenkins for streamlined AWS infrastructure management. Leveraging Infrastructure as Code (IaC), automate EC2 provisioning for efficient, reliable deployments.

## Technologies
**Ansible**: Automates AWS resource provisioning and configuration.
**Jenkins**: Manages deployment pipelines and integrates with Ansible for continuous integration.
**AWS**: Provides scalable cloud computing resources.
**Docker**: Facilitates application containerization for versatile deployments.
**Trivy**: Performs security scanning to identify system vulnerabilities.
**Boto/Boto3**: Python libraries for AWS interactions.
**GitHub**: Hosts our code repository for collaboration and version control.

## Project Architecture

![arch](screenshots/arch.avif)

## Project steps:

Step 1: Launch ec2 instance with t2.micro and ubuntu AMI. I have used following terraform file to launch it.


```
    provider "aws" {
      region = "us-east-1" # Change this to your desired AWS region
    }

    resource "aws_instance" "my_instance" {
      count = 1


      ami                    = "ami-0fc5d935ebf8bc3bc" # Specify the AMI ID for your desired Amazon Machine Image
      instance_type          = "t2.medium"
      key_name               = "linux-kp" # Change this to your key pair name
      vpc_security_group_ids = [aws_security_group.terraform-instance-sg.id]


      tags = {
        Name = "CI-CD"
      }


    }

    output "jenkins_public_ip" {
        value = [for instance in aws_instance.my_instance : instance.public_ip]

    }



    #Create security group 
    resource "aws_security_group" "terraform-instance-sg" {
      name        = "terraform-created-sg"
      description = "Allow inbound ports 22, 8080"
      vpc_id      = "vpc-0bb95d14e92638eb6"

      #Allow incoming TCP requests on port 22 from any IP
      ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      #Allow incoming TCP requests on port 443 from any IP
      ingress {
        description = "Allow HTTPS Traffic"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      #Allow incoming TCP requests on port 8080 from any IP
      ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      #Allow incoming TCP requests on port 8080 from any IP
      ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }


      #Allow all outbound requests
      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
```
![ec2](screenshots/ec2terraform.png)
![ec2](screenshots/ec2.png)

Install Jenkins and Trivy :

SSH into created ec2 instance and make following .sh files to install required package

**jenkins-install.sh**
```
 #!/bin/bash

 sudo apt update -y
 sudo apt install fontconfig openjdk-17-jre -y
 sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
   https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
 echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
   https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
   /etc/apt/sources.list.d/jenkins.list > /dev/null
 sudo apt-get update -y
 sudo apt-get install jenkins -y
 sudo systemctl enable jenkins
 sudo systemctl start jenkins
 sudo systemctl status jenkins
```

![jenkins](screenshots/jenkins-install.png)
