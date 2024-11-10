resource "aws_security_group" "jupiter_server_sg" {
  name        = "jupiter_server_sg"
  description = "Allow SSH, HTTP and HTTPS traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_tls"
  }
}

#CREATING INBOUND SECURITY GROUP FOR  JUPITER SERVER-----------------------------------------
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  referenced_security_group_id = var.alb_sg 
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  referenced_security_group_id = var.alb_sg 
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


#CREATING OUTBOUND SECURITY GROUP FOR  JUPITER SERVER------------------------------------------------
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#CREATING LAUNCH TEMPLATE FOR JUPITER SERVER----------------------------------------------------------
resource "aws_launch_template" "apci_lt" {
  name_prefix   = "apci_lt"
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name = var.key_name
  user_data = base64encode(file("Script/frontend-server.sh"))

    network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.jupiter_server_sg.id]
  }
}

#CREATE AUTO-SCALING GROUP
resource "aws_autoscaling_group" "apci_asg" {
  name                      = "apci-asg"
  max_size                  = 8
  min_size                  = 4
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 6
  force_delete              = true
  vpc_zone_identifier       = [var.frontend_subnet_az1a_id, var.frontend_subnet_az1b_id]
  target_group_arns = var.target_group_arn

  launch_template {
    id      = aws_launch_template.apci_lt.id
    version = "$Latest"

  }
}