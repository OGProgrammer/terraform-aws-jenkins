#!/usr/bin/env bash
#This is just a helper script for setting up github, you'll want to run this manually on your production jenkins
# Add user information to git global config. This allows Jenkins to push updates to github repos
echo "Setting up github creds"
git config --global user.email "Jenkins@YourCompany"
git config --global user.name "Jenkins"

echo "Generating new SSH Key pair"
ssh-keygen -t rsa -C "Jenkins@YourCompany" -f "/var/lib/jenkins/.ssh/id_rsa" -P ""

echo "Starting SSH Agent..."
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

echo "Please add the following public key to a github account at https://github.com/settings/keys"
echo ""
cat ~/.ssh/id_rsa.pub
echo ""
echo "After you add the key to your profile, try and clone a repo"
echo ""
echo "git clone git@github.com:OGProgrammer/jenkins-pipeline-groovy.git /tmp/test"
echo ""
echo "You will be prompted to check the fingerprint of github."
echo "If you're paranoid about MITM attacks, verify the fingerprint at:"
echo "https://help.github.com/articles/github-s-ssh-key-fingerprints/"
echo "Type 'yes' and hit enter if they match and you are all set"