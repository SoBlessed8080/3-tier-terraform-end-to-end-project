output "vpc_id" {
  value = aws_vpc.apci_main_vpc.id
}

output "frontend_subnet_az1a_id" {
  value= aws_subnet.frontend_subnet_az1a.id
}

output "frontend_subnet_az1b_id" {
  value= aws_subnet.frontend_subnet_az1b.id
}
