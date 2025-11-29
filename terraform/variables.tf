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
  default     = "ZBF1C0OM7KPJY"  # ISKCON.org
}

variable "load_balancer_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
  default     = "arn:aws:elasticloadbalancing:us-east-1:793753096261:loadbalancer/app/ICG-ELB/ed8f2ac6e693c7b2"
}

variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for the ELB"
  type        = string
  default     = "arn:aws:acm:us-east-1:793753096261:certificate/c9bb28af-b8d0-44ba-8fac-ed3642605809"
}
