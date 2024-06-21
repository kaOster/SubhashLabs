
output "serverA_public_ip" {
  description = "Server A EC2 IP Address"
  value = aws_instance.myproj2-serverA.public_ip

}


output "serverB_public_ip" {
  description = "Server B EC2 IP Address"
  value = aws_instance.myproj2-serverB.public_ip

}

