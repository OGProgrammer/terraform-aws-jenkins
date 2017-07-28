output "jenkins_public_ip" {
  value = "${aws_instance.jenkins_ec2.public_ip}"
}

output "jenkins_ec2_id" {
  value = "${aws_instance.jenkins_ec2.id}"
}