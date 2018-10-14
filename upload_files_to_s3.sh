#!/bin/sh
echo "REPOSITORY: terraform-aws-jenkins"
echo "SCRIPT: upload_files_to_s3.sh <s3prefix> <region>"
echo "EXECUTING: upload_files_to_s3.sh"

s3_prefix=$1
if [ -z "$s3_prefix" ]; then
    echo "An s3prefix must be provided! Failing out."
fi

target_aws_region=$2
if [ -z "$target_aws_region" ]; then
    target_aws_region=us-west-2
    echo "No region was passed in, using \"${target_aws_region}\" as the default"
fi

# Use this file to upload the init.sh file to S3
echo "Uploading Jenkins Files to S3 - Used to replace things on jenkins during boot"
aws s3 cp --recursive ./files/ s3://${s3_prefix}-jenkins-files-${target_aws_region}/

echo "# # # # # # # # E N D # # # # # # # # # #"