# terraform-aws-jenkins
An AWS EC2 setup running Jenkins provisioned via Terraform.

## Requirements

* Terraform 0.9+

## Prerequisites
 
* Please ensure you have the `aws` cli application working from where you will be running the `terraform.sh` script.

* Before you run this repo, ensure you've ran the [`terraform-aws-init` repo](https://github.com/OGProgrammer/terraform-aws-init). That will ensure you have the `terraform-states` s3 bucket and a `root-ssh-key` for shell access to jenkins.
