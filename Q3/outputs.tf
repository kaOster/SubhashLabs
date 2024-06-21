
output "ec2_public_ip" {
  description = "Amazon Linux EC2 IP Address"
  value = aws_instance.myproj3-ec2.public_ip

}

