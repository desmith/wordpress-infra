# WordPress on AWS Graviton

This project provisions a WordPress instance on AWS using Graviton (ARM64) processors with Terraform and Ansible.

## Prerequisites

- Terraform >= 1.0
- Ansible >= 2.9
- AWS CLI configured with appropriate credentials
- An AWS key pair for SSH access

## Usage

### 1. Configure Variables

Edit `terraform/vars/graviton.tfvars` with your settings:

- `key_pair_name`: Your AWS key pair name
- `ssh_cidr`: Your IP address for SSH access (restrict in production)
- `db_password`: Secure database password

### 2. Initialize and Apply Terraform

```shell
cd terraform

terraform init
terraform plan -var-file=vars/graviton.tfvars
terraform apply -var-file=vars/graviton.tfvars
```

### 3. Get Instance IP

```shell
terraform output instance_public_ip
```

### 4. Update Ansible Inventory

Edit `ansible/inventory.ini` with the instance IP from step 3, or use dynamic inventory.

```shell
[wordpress]
wordpress ansible_host=<PUBLIC_IP> ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/your-key.pem
```

### 5. Install Ansible Roles

```shell
just ansible-install

or

cd ansible && ansible-galaxy install -r requirements.yml
```

### 6. Update Ansible Inventory

```shell
just ansible-update-roles

or

cd ansible
ansible-galaxy install -r requirements.yml --force
```

### 6. Run Ansible Playbook

```shell
just ansible

or

cd ansible
ansible-playbook -i inventory.ini playbook.yml \
  -e "wordpress_admin_password=your-secure-password" \
  -e "db_password=$(terraform -chdir=../terraform output -raw db_password)"
```

### 6. Access WordPress

Visit `http://<instance-ip>` in your browser to complete WordPress setup.

## Graviton Instance Types

Common Graviton instance types:

- `t4g.nano` - 2 vCPU, 0.5 GB RAM
- `t4g.micro` - 2 vCPU, 1 GB RAM
- `t4g.small` - 2 vCPU, 2 GB RAM
- `t4g.medium` - 2 vCPU, 4 GB RAM (recommended minimum for WordPress)
- `t4g.large` - 2 vCPU, 8 GB RAM

## Notes

- The instance uses Amazon Linux 2023 ARM64 AMI
- WordPress is installed in `/var/www/wordpress`
- Database is MariaDB (local) unless `db_host` is specified
- Security groups allow HTTP (80), HTTPS (443), and SSH (22)

### Justfile Commands

```shell
just --list
```

#### Initialize Terraform

```shell
just init
```

#### Plan changes

```shell
just plan
```

#### Apply changes (with confirmation)

```shell
just apply
```

#### Apply changes (auto-approve)

```shell
just apply auto-approve=true
```

#### Destroy infrastructure

```shell
just destroy
```

#### Run Ansible playbook

```shell
just ansible
```

#### Run Ansible with extra variables

```shell
just ansible-with-vars admin-password="secure123" db-password="dbpass123"
```

#### Full deployment workflow

```shell
just deploy
```

#### Use different environment

```shell
just plan environment=dev
just apply environment=dev
just ansible environment=dev
```

#### Show Terraform outputs

```shell
just output
```

#### Get instance IP

```shell
just get-ip
```
