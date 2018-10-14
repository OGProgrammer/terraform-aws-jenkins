# Jenkins Terraform Goodness :)
# @author Joshua Copeland <JoshuaRCopeland@gmail.com>


# Keeping your terraform.state files locally or commited in version control is generally a bad idea.
# Hence why we are telling terraform to use "s3" as our "backend" to put state files into
terraform {
  backend "s3" {
  }
}

# This tells terraform we will use AWS. Your key/secret is being set via env vars to magically get set into this node.
provider "aws" {
  # If you have other AWS accounts, use this profile marker to point to specific credentials.
#  profile = "your-profile-name"
  version = "~> 0.1"
  region = "${var.region}"
}

provider "template" {
  version = "~> 0.1"
}

# Where to store the terraform state file. Note that you won't have a local tfstate file, because its stored remotly.
data "terraform_remote_state" "jenkins_state" {
  backend = "s3"
  config {
    bucket = "${var.s3prefix}-terraform-states-${var.region}"
    key = "${var.env_name}/jenkins.tfstate"
    region = "${var.region}"
  }
}

# This is the entry point script for our jenkins instance. This installs jenkins and req deps.
data "template_file" "jenkins_userdata" {
  template = "${file("userdata.tpl")}"

  vars {
    EnvName = "${var.env_name}"
    # The name of the bucket that will store our Jenkins resources. This was created in terraform-aws-init
    JenkinsBucket = "${var.s3prefix}-jenkins-files-${var.region}"
  }
}

# The EC2 instance to go spin up with a fresh Debian AMI, userdata script installs Jenkins + other cool stuff
resource "aws_instance" "jenkins_ec2" {
  ami = "${lookup(var.aws_amis, var.region)}"
  instance_type = "${var.instance_type}"
  key_name = "${var.ssh_key_name}"
  vpc_security_group_ids = [
    "${aws_security_group.public.id}"
  ]
  subnet_id = "${element(aws_subnet.public.*.id, 0)}"
  associate_public_ip_address = true
  source_dest_check           = false
  iam_instance_profile        = "${aws_iam_instance_profile.jenkins_profile.name}"
  user_data                   = "${data.template_file.jenkins_userdata.rendered}"

  tags {
    Name = "${var.env_name}-${var.region}"
    ManagedBy = "Terraform"
    IamInstanceRole = "${aws_iam_role.jenkins_iam_role.name}"
  }

  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_type = "standard"
    volume_size = "250"
    # Safe guard for your jenkins and docker data
    delete_on_termination = "false"
  }
}

# This is our main AWS Virtual Private Cloud we will launch jenkins into.
resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"

  tags {
    Name = "tf-${var.env_name}-vpc"
    ManagedBy = "Terraform"
  }
}

# This is so we can get an ouside connection.
resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    ManagedBy = "Terraform"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.main.id}"
}

# Create a subnet for each availability zone
resource "aws_subnet" "public" {
  count = "${length(split(",",var.availability_zones))}"
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, count.index+1)}"
  map_public_ip_on_launch = true
  availability_zone = "${element(split(",",var.availability_zones), count.index)}"

  tags {
    Name = "${format("tf-aws-${var.env_name}-public-%03d", count.index+1)}"
    ManagedBy = "Terraform"
  }
}


# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "public" {
  name = "tf-${var.env_name}-public-sg"
  description = "Managed By Terraform"
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "tf-${var.env_name}-public-sg"
    ManagedBy = "Terraform"
  }

  # SSH
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  # Jenkins Web UI
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  # Outbound Traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}