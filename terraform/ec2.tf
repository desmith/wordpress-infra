# EC2 Instance (Graviton)
resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  subnet_id              = var.subnet_id

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y python3 python3-pip
              pip3 install boto3

              # Ensure SSM Agent is running (pre-installed on AL2023)
              systemctl enable amazon-ssm-agent
              systemctl start amazon-ssm-agent
              EOF

  tags = {
    Name        = "${var.env}.${var.project_name}"
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}

# Elastic IP
resource "aws_eip" "webserver_eip" {
  instance = aws_instance.webserver.id
  domain   = "vpc"

  tags = {
    Name = "${var.env}.${var.project_name}"
  }
}

# Security group rule to allow SSH from current workstation IP
# This rule will be added to the AdminSG (sg-02fb8ee3c8ace0441)
resource "aws_security_group_rule" "admin_sg_ssh_from_workstation" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.ssh_cidr]
  security_group_id = "sg-02fb8ee3c8ace0441"
  description       = "Current workstation IP - via Terraform"

  lifecycle {
    create_before_destroy = true
  }
}
