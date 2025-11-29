resource "aws_security_group" "admin_sg" {
  name        = "${var.env}-${var.project_name}-admin-sg"
  description = "Security group for the admin instance"
  vpc_id      = local.vpc_id
}

# Security group rule to allow SSH from current workstation IP
resource "aws_security_group_rule" "admin_sg_ssh_from_workstation" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.ssh_cidr]
  security_group_id = aws_security_group.admin_sg.id
  description       = "Current workstation IP - via Terraform"

  lifecycle {
    create_before_destroy = true
  }
}
