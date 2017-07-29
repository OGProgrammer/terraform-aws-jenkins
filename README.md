# terraform-aws-jenkins
An AWS EC2 setup running Jenkins provisioned via Terraform.

## Requirements

* Terraform 0.9+

## Prerequisites
 
* Please ensure you have the `aws` cli application working

* Before you run this repo, ensure you've ran the [`terraform-aws-init` repo](https://github.com/OGProgrammer/terraform-aws-init). That will ensure you have the `terraform-states` s3 bucket and a `root-ssh-key` for shell access to jenkins.

## Instructions

The scripts can be called with the following parameters:

`tf-plan.sh <env_name> <region> <availability_zones> <ssh_key_name>`

You can leave these blank if you provisioned in us-west-2 and just launch `./tf-plan.sh`

Once the plan runs and everything looks good, you can provision your jenkins instance by running `./tf-apply.sh`

That is all there is to it! You can then see the IP of your Jenkins instance and ssh or browse to it.

To ssh `ssh admin@x.x.x.x`

Jenkins UI can be seen browsed at `x.x.x.x:8080` where x.x.x.x is the output IP address of the ec2 instance.