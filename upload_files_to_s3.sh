#!/bin/sh
echo "REPOSITORY: terraform-aws-jenkins"
echo "SCRIPT: upload_files_to_s3.sh <region>"
echo "EXECUTING: upload_files_to_s3.sh us-east-1"

target_aws_region=$2
if [ -z "$target_aws_region" ]; then
    target_aws_region=us-west-2
    echo "No region was passed in, using \"${target_aws_region}\" as the default"
fi

# Use this file to upload the init.sh file to S3
echo "Uploading Jenkins Files to S3 - Used to replace things on jenkins during boot"
aws s3 cp --recursive ./files/ s3://jenkins-files-${target_aws_region}/