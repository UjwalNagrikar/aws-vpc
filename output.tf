output "aws_instance" {
  value = aws_instance.Ujwal-Server.public_ip
}

output "aws_vpc" {
  value = aws_vpc.Ujwal-VPC.id
}