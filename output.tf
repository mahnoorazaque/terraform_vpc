output "public_instance_ip" {
    value = aws_instance.public_instance.public_ip
}

output "private_instance_private_ip" {
    value = aws_instance.private_instance.private_ip
}

output "vpc_id" {
    value = aws_vpc.main.id
}

output "nat_gateway_ip" {
    value = aws_eip.nat.public_ip
}
