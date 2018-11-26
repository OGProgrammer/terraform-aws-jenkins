# terraform-aws-jenkins
An AWS EC2 setup running Jenkins provisioned via Terraform.

## Requirements

* Terraform 0.9+

## Prerequisites
 
* Please ensure you have the `aws` cli application working

* Before you run this repo, ensure you've ran the [`terraform-aws-init` repo](https://github.com/OGProgrammer/terraform-aws-init). That will ensure you have the `terraform-states` s3 bucket and a `root-ssh-key` for shell access to jenkins.

## Instructions

The scripts can be called with the following parameters:

`tf-plan.sh <s3_prefix> <env_name> <region> <availability_zones> <ssh_key_name>`

You must pass in the *s3prefix* you used in the `terraform-aws-init` s3prefix to this script. Ex. `./tf-plan.sh optimus-prime-87`

Once the plan runs and everything looks good, you can provision your jenkins instance by running `./tf-apply.sh <s3_prefix>`

That is all there is to it! You can then see the IP of your Jenkins instance and ssh or browse to it.

To ssh `ssh admin@x.x.x.x`

Jenkins UI can be seen browsed at `x.x.x.x:8080` where x.x.x.x is the output IP address of the ec2 instance.

*PLEASE SECURE JENKINS ASAP BY PUTTING INTO A PRIVATE SUBNET OR ADDING PASSWORD AUTH*

### Post Instructions

After Jenkins is setup, you'll need to start editing configs in your forked `terraform-example-manifest` repo that you created earlier.

SSH into your Jenkins instance and do the following:

#### Setup GitHub Credentials with Jenkins

 * SSH into the Jenkins EC2 and switch to the Jenkins user. Move to the Jenkins home directory.
    
    `sudo su jenkins && cd ~/`
    
 * Run the git config script
    
    `./configure-git.sh`
    
 * Copy/Paste your key into GitHub and Save *
 * Clone something from GitHub in the CLI on the Jenkins server and accept the fingerprint.

#### Setup Docker Credentials with Jenkins

##### Instructions when using your own DockerHub account:

 * Login to your Docker account via CLI
 
    `docker login`

 * Copy the token from the `~./docker/config.json` file

 * In your forked `terraform-example-manifest` repo, edit the `docker.json` file.

   * Update `dockerhub_email` with your docker hub email.

   * Update `dockerhub_token` with the token you just copied from the config.json file.

##### Instructions when using premade DockerHub account

 * Make sure you switch to the Jenkins user.
 
 `sudo su jenkins && cd ~/`

 * Create the “.docker” directory

 `mkdir ~/.docker`

 * Create a ~./docker/config.json file

 `vim ~/.docker/config.json`

 * Paste the following into this file:
```
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "dGhpc2lzanVzdGF0ZXN0OnRlY2h0djEyMQ=="
    }
  }
}
```

##### Your manifest (config) repo for your environment variables

* Fork the [terraform-example-manifest](https://github.com/OGProgrammer/terraform-example-manifest) repo and *change the `terraform.json` file with your s3 prefix*. Push that change up and copy the github ssh clone url. 

* Head over to your Jenkins instance in a web browser and click Manage Jenkins -> Configure System -> Check off Environment Variables and add one called MANIFEST_REPO and paste your manifest url you copied earlier here. Ex. `git@github.com:OGProgrammer/terraform-example-manifest.git`

##### Setup Jenkins Jobs

Follow from slide 36 and on for how to setup the rest of the dev/prod jobs. 

*[Google Slides can be found here](https://docs.google.com/presentation/d/1KeZn1z-p2zWoeeI8hxI-B7DI1wkBDjSjXU5_k1OsjJM/edit?usp=sharing)*

## Important Notes

If you provision this Jenkins terraform script with something that deletes and creates a new Jenkins instance,
(because yes that can happen) don't freak out. You can login to the AWS EC2->Volumes page and detach the new drive and add the old one back.
All your Jenkins/Docker data should be stored on this volume.

1. SSH into Jenkins and stop Jenkins `sudo service jenkins stop`
2. Unmount the new drive `sudo umount /dev/xvdf`
3. Detach the [volume](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Volumes:sort=desc:createTime) in the AWS dashboard.


Delete drives not in use anymore as they will pile up even after a terraform destroy.

### Destroying

Just run `./tf-destroy.sh <s3_prefix>` but in order to finalize cleanup you'll need to delete one last thing manually.

*There is a 250 GB drive mounted to Jenkins that is not destroyed when you destroy the instance with terraform, you have to manually goto [AWS EC2 Volumes](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Volumes:sort=desc:createTime) and destroy the drive that way.*

This is to prevent critical production data from getting destroyed but yea, I even keep forgetting to kill these drives...

#### TODOs

* This could probably be further improved by using Ansible, Puppet, Chef, or something like that to provision any OS. This is really locked to Debian at the moment.

* Have a way to automatically create the jenkins jobs based off a manifest in s3.

* Combine jobs for less work (plan and apply in one) but more risk unless you add an approval step.

* Refactor groovy scripts to look for credentials for docker and github rather than going onto box to configure.

```
Built & Maintained by @OGProgrammer

Support Your Local User Groups
http://php.ug/

Check out our PHP UG in Las Vegas, NV
http://PHPVegas.com

Support your local tech scene!
#VegasTech

Share your knowledge!
Become a speaker, co-organizer, at your local user groups.
Contribute to your favorite open source packages (even if its a README ;)

Thank you! ☺

-Josh

Paid support and training services available at http://RemoteDevForce.com
```

Slides: https://docs.google.com/presentation/d/1KeZn1z-p2zWoeeI8hxI-B7DI1wkBDjSjXU5_k1OsjJM/edit?usp=sharing
