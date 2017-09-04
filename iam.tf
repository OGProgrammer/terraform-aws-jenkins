# Jenkins IAM Policies, Role+Policy Attachements, & the Role itself to attach to Jenkins
# These permissions are currently very liberal, lock this down once you define what your Jenkins instance will do

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.env_name}-${var.region}"
  role = "${aws_iam_role.jenkins_iam_role.name}"
}

# A shared IAM role for jenkins which has two policy documents attached. IAM stuff & Power User Access.
# I added the region in the name
resource "aws_iam_role" "jenkins_iam_role" {
  name = "${var.env_name}-${var.region}"
  path = "/"
  assume_role_policy = "${data.aws_iam_policy_document.jenkins-assume-role-policy.json}"
}
# Needed to assume an instance role
data "aws_iam_policy_document" "jenkins-assume-role-policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

# Lets just give power user access to avoid permission issues.
# This is something to revisit going into production on what IAM perms you actually need.
# @todo It's is on you to restrict this jenkins role to your security requirements.
resource "aws_iam_role_policy_attachment" "poweruser-attach" {
  role = "${aws_iam_role.jenkins_iam_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy_attachment" "iam-control-attach" {
  role = "${aws_iam_role.jenkins_iam_role.name}"
  policy_arn = "${aws_iam_policy.jenkins-iam-control-policy.arn}"
}

resource "aws_iam_policy" "jenkins-iam-control-policy" {
  name        = "${var.env_name}-${var.region}-iam-control"
  description = "Give full control over IAM "
  policy = "${data.aws_iam_policy_document.jenkins-iam-control-policy.json}"
}

# Needed to provision resources in AWS from the Jenkins instance
data "aws_iam_policy_document" "jenkins-iam-control-policy" {
  statement {
    effect = "Allow"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreatePolicy",
      "iam:CreateRole",
      "iam:DeletePolicy",
      "iam:DeleteRole",
      "iam:DetachRolePolicy",
      "iam:PassRole",
      "iam:GetRole",
      "iam:GetGroup",
      "iam:GetPolicy",
      "iam:GetRolePolicy",
      "iam:GetInstanceProfile",
      "iam:ListAttachedRolePolicies",
      "iam:ListEntitiesForPolicy",
      "iam:ListRolePolicies",
      "iam:ListRoles",
      "iam:PutRolePolicy"
    ]
    resources = ["*"]
  }
}
