# If you want to make more than one Jenkins, this env_name is all that needs to change
variable "env_name" {
  description = "The name of the environment and resource namespacing."
}

# Where to place Jenkins
variable "region" {
  description = "The target AWS region"
}

# An s3 prefix (Your unique stack name)
variable "s3prefix" {
  description = "A unique s3 prefix to add for our bucket names"
}

# This is the root ssh key used for the ec2 instance
variable "ssh_key_name" {
  description = "The name of the preloaded root ssh key used to access AWS resources."
}

# Your best bet to find how many AZs there are is this list https://aws.amazon.com/about-aws/global-infrastructure/
# Assume it starts with "a" times how many AZs are available
variable "availability_zones" {
  description = "List of availability zones"
}

# The instance size we will use for Jenkins (I recommend large or higher for prod)
variable "instance_type" {
  description = "AWS instance type for Jenkins"
  default = "t2.medium"
}

# My personal perference is Debian, however I've seen others use CentOS/RedHat.
# If you do change the Linux Distro, you might need to change the intall cmds used.
# Amazon AMI is Debian 8.7 - https://wiki.debian.org/Cloud/AmazonEC2Image/Jessie
variable "aws_amis" {
  type = "map"
  default = {
    "ap-northeast-1" = "ami-dbc0bcbc"
    "ap-northeast-2" = "ami-6d8b5a03"
    "ap-south-1" = "ami-9a83f5f5"
    "ap-southeast-1" = "ami-0842e96b"
    "ap-southeast-2" = "ami-881317eb"
    "ca-central-1" = "ami-a1fe43c5"
    "eu-central-1" = "ami-5900cc36"
    "eu-west-1" = "ami-402f1a33"
    "eu-west-2" = "ami-87848ee3"
    "sa-east-1" = "ami-b256ccde"
    "us-east-1" = "ami-b14ba7a7"
    "us-east-2" = "ami-b2795cd7"
    "us-west-1" = "ami-94bdeef4"
    "us-west-2" = "ami-221ea342"
  }
}