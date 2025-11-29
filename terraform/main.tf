# Local value to construct subdomain name
locals {
  subdomain_name = "${var.env}.iskcon.org"
  vpc_id = data.aws_subnet.webserver.vpc_id
  ssh_cidr = "${chomp(data.http.current_ip.response_body)}/32"
  target_group_name = replace(replace("${var.env}-${var.project_name}-tg", ".", ""), " ", "")
  listener_rule_name = replace(replace("${var.project_name}-${var.env}", ".", "-"), " ", "")
  listener_rule_priority = 9


}

# Get home directory
data "external" "home_dir" {
  program = ["sh", "-c", "echo '{\"home\":\"'$HOME'\"}'"]
}

# Get current workstation public IP address
data "http" "current_ip" {
  url = "https://api.ipify.org"

  request_headers = {
    Accept = "text/plain"
  }
}

# Get the latest Amazon Linux 2023 AMI for Graviton
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get the load balancer details
data "aws_lb" "existing_lb" {
  arn = var.load_balancer_arn
}

# Get existing HTTPS listener
data "aws_lb_listener" "https" {
  load_balancer_arn = data.aws_lb.existing_lb.arn
  port              = 443
}
# Get subnet details to determine VPC ID
data "aws_subnet" "webserver" {
  id = var.subnet_id
}

# Generate Ansible inventory file
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    instance_ip   = aws_eip.webserver_eip.public_ip
    key_pair_name = var.key_pair_name
    env           = var.env
  })
  filename = "${path.module}/../ansible/inventory.ini"
}


# Generate SSH config file
resource "local_file" "ssh_config" {
  content = templatefile("${path.module}/templates/ssh_config.tpl", {
    host_name     = "${var.env}.${var.project_name}"
    instance_ip   = aws_eip.webserver_eip.private_ip
    key_pair_name = var.key_pair_name
    env           = var.env
  })
  filename             = "${data.external.home_dir.result.home}/.ssh/conf.d/icg-${var.env}.ssh"
  file_permission      = "0644"
  directory_permission = "0755"
}
