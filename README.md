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

## Important Notes

If you provision this Jenkins terraform script with something that deletes and creates a new Jenkins instance,
(because yes that can happen) don't freak out. You can login to the AWS EC2->Volumes page and detach the new drive and add the old one back.
All your Jenkins/Docker data should be stored on this volume.

1. SSH into Jenkins and stop Jenkins `sudo service jenkins stop`
2. Unmount the new drive `sudo umount /dev/xvdf`
3. Detach the [volume](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Volumes:sort=desc:createTime) in the AWS dashboard.


Delete drives not in use anymore as they will pile up even after a terraform destroy.

### Destroying

Just run `./tf-destroy.sh` but in order to finalize cleanup you'll need to delete one last thing manually.

*There is a 250 GB drive mounted to Jenkins that is not destroyed when you destroy the instance with terraform, you have to manually goto [AWS EC2 Volumes](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Volumes:sort=desc:createTime) and destroy the drive that way.*

This is to prevent critical production data from getting destroyed but yea, I even keep forgetting to kill these drives...

#### TODOs

This could probably be further improved by using Ansible, Puppet, Chef, or something like that to provision any OS. This is really locked to Debian at the moment.
