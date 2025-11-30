data "aws_secretsmanager_secret" "db_secrets" {
  name = var.secrets_name
}

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

# Get current workstation public IP address
data "http" "current_ip" {
  url = "https://api.ipify.org"

  request_headers = {
    Accept = "text/plain"
  }
}

# Get home directory
data "external" "home_dir" {
  program = ["sh", "-c", "echo '{\"home\":\"'$HOME'\"}'"]
}

# Get the latest Amazon Linux 2023 AMI for Graviton
# Get existing listener rules to determine next priority
data "external" "listener_rules" {
  program = ["sh", "-c", <<-EOT
    aws elbv2 describe-rules \
      --listener-arn "${data.aws_lb_listener.https.arn}" \
      --query 'Rules[?Priority!=`default`].Priority' \
      --output json | \
    jq -r 'if length > 0 then [.[] | tonumber] | max + 1 else 1 end'
  EOT
  ]
}
