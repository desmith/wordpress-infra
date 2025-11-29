variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "hostname" {
  description = "Hostname for the instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (must be Graviton/ARM64 compatible)"
  type        = string
  default     = "t4g.nano"
}

variable "key_pair_name" {
  description = "Name of the AWS key pair for SSH access"
  type        = string
}

variable "ssh_cidr" {
  description = "CIDR block for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
  default     = [
    "sg-02fb8ee3c8ace0441", # AdminSG
    "sg-94c8cee3"  # WebAppSG
    ]
}

variable "subnet_id" {
  type        = string
  default     = "subnet-5b4d9954"
}

variable "hosted_zone_id" {
  description = "Route 53 hosted zone ID for the domain"
  type        = string
}

variable "load_balancer_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}

variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for the ELB"
  type        = string
}

variable "secrets_name" {
  description = "Name of the AWS Secrets Manager secret"
  type        = string
}

# Database secrets
variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Username for the database"
  type        = string
}

variable "wp_admin_user" {
  description = "Username for the WordPress admin user"
  type        = string
  default     = "admin"
}

variable "wp_admin_email" {
  description = "Email for the WordPress admin user"
  type        = string
}

