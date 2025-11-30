# Default project name
default-project_name := "WordPressInfra"

# Default environment
default-environment := "dev"

# Default hostname
default-hostname := "WordPressInfra.iskcon.org"

# Terraform directory
terraform-dir := "terraform"

# Ansible directory
ansible-dir := "ansible"

# Show all available targets
list:
    @just --list

# Show help for a specific target
help target:
    @just --help {{target}}

# Get secrets name from project name and environment
get-secrets-name project_name=default-project_name environment=default-environment:
    #!/usr/bin/env bash
    echo "{{project_name}}/{{environment}}/rds"

# Generate backend config from template
[group: "Terrafor"]
generate-backend \
    hostname=default-hostname \
    project_name=default-project_name \
    environment=default-environment:
    #!/usr/bin/env bash
    set -e
    echo "Generating backend config..."

    # Get secrets name
    secrets_name=$(just get-secrets-name {{project_name}} {{environment}})
    echo "Secrets name: ${secrets_name}"

    # Generate backend config from template
    cd {{terraform-dir}}
    sed -e "s/PROJECT_NAME/{{project_name}}/g" \
        -e "s/ENV/{{environment}}/g" \
        vars/env.tfbackend.tpl > vars/{{environment}}.tfbackend

    sed -e "s/HOSTNAME/{{hostname}}/g" \
        -e "s/PROJECT_NAME/{{project_name}}/g" \
        -e "s/ENV/{{environment}}/g" \
        -e "s|SECRETS_NAME|${secrets_name}|g" \
        vars/env.tfvars.tpl > vars/{{environment}}.tfvars

    echo "Generated configs: "
    echo "  - vars/{{environment}}.tfbackend"
    echo "  - vars/{{environment}}.tfvars"

# Initialize Terraform
[group: "Terraform"]
init \
    hostname=default-hostname \
    project_name=default-project_name \
    environment=default-environment: \
    (generate-backend hostname project_name environment)
    #!/usr/bin/env bash
    set -e
    cd {{terraform-dir}}
    tfenv install
    tfenv use
    terraform version
    terraform init \
    -backend-config="./vars/{{environment}}.tfbackend" \
    -reconfigure

# Plan Terraform changes
[group: "Terraform"]
plan environment=default-environment: validate
    #!/usr/bin/env bash
    set -e
    cd {{terraform-dir}}
    terraform plan \
    -var-file="vars/{{environment}}.tfvars" \
    -out=tfplan
    terraform show -no-color tfplan > tfplan.txt

# Deploy (alias for apply)
[group: "Terraform"]
deploy environment=default-environment: (apply environment)

# Apply Terraform changes
[group: "Terraform"]
apply environment=default-environment: (plan environment)
    #!/usr/bin/env bash
    set -e
    cd {{terraform-dir}}
    terraform apply \
    -var-file="vars/{{environment}}.tfvars" \
    tfplan

# Destroy Terraform infrastructure
[group: "Terraform"]
destroy environment=default-environment:
    #!/usr/bin/env bash
    set -e
    cd {{terraform-dir}}
    terraform destroy \
        -var-file="vars/{{environment}}.tfvars" \
        -auto-approve

# Show Terraform outputs
[group: "Terraform"]
output environment=default-environment:
    cd {{terraform-dir}}
    terraform output

# Get instance IP from Terraform output
[group: "Terraform"]
get-ip environment=default-environment:
    cd {{terraform-dir}}
    terraform output -raw instance_public_ip

# Install Ansible collections and roles
[group: "Ansible"]
ansible-install environment=default-environment:
    #!/usr/bin/env bash
    set -e
    cd {{ansible-dir}}

    # Always install/update collections and roles
    echo "Installing/updating Ansible collections and roles..."
    # Install collections to ./collections
    ansible-galaxy collection install -r requirements.yml -p ./collections --force
    # Install roles to ./roles (respects roles_path in ansible.cfg)
    ansible-galaxy role install -r requirements.yml -p ./roles --force

# Run Ansible playbook
[group: "Ansible"]
ansible \
    hostname=default-hostname \
    project_name=default-project_name \
    environment=default-environment \
    *args:
    #!/usr/bin/env bash
    set -e
    cd {{ansible-dir}}

    # Get secrets name
    secrets_name=$(just get-secrets-name {{project_name}} {{environment}})

    # Always install/update collections and roles
    echo "Installing/updating Ansible collections and roles..."
    # Install collections to ./collections
    ansible-galaxy collection install -r requirements.yml -p ./collections
    # Install roles to ./roles (respects roles_path in ansible.cfg)
    ansible-galaxy role install -r requirements.yml -p ./roles

    # Get environment from tfvars (fallback to parameter if not found)
    # TF_ENV=$(grep -E '^env\s*=' ../{{terraform-dir}}/vars/{{environment}}.tfvars 2>/dev/null | cut -d'"' -f2 || echo "{{environment}}")

    # Use the generated inventory file
    ansible-playbook \
        -i inventory.ini \
        -e "env={{environment}}" \
        -e "hostname={{hostname}}" \
        -e "secrets_name=${secrets_name}" \
        playbook.yml {{args}}

# Run only the al2023 role
[group: "Ansible"]
ansible-al2023 \
    hostname=default-hostname \
    project_name=default-project_name \
    environment=default-environment \
    *args:
    #!/usr/bin/env bash
    set -e
    cd {{ansible-dir}}

    # Get secrets name
    secrets_name=$(just get-secrets-name {{project_name}} {{environment}})

    # Always install/update collections and roles
    echo "Installing/updating Ansible collections and roles..."
    ansible-galaxy collection install -r requirements.yml -p ./collections
    ansible-galaxy role install -r requirements.yml -p ./roles

    # Run only al2023 role
    ansible-playbook \
        -i inventory.ini \
        -e "env={{environment}}" \
        -e "hostname={{hostname}}" \
        -e "secrets_name=${secrets_name}" \
        --tags al2023 \
        playbook.yml {{args}}

# Run only the php role
[group: "Ansible"]
ansible-php \
    hostname=default-hostname \
    project_name=default-project_name \
    environment=default-environment \
    *args:
    #!/usr/bin/env bash
    set -e
    cd {{ansible-dir}}

    # Get secrets name
    secrets_name=$(just get-secrets-name {{project_name}} {{environment}})

    # Always install/update collections and roles
    echo "Installing/updating Ansible collections and roles..."
    ansible-galaxy collection install -r requirements.yml -p ./collections
    ansible-galaxy role install -r requirements.yml -p ./roles

    # Run only php role
    ansible-playbook \
        -i inventory.ini \
        -e "env={{environment}}" \
        -e "hostname={{hostname}}" \
        -e "secrets_name=${secrets_name}" \
        --tags php \
        playbook.yml {{args}}

# Run only the wordpress role
[group: "Ansible"]
ansible-wordpress \
    hostname=default-hostname \
    project_name=default-project_name \
    environment=default-environment \
    *args:
    #!/usr/bin/env bash
    set -e
    cd {{ansible-dir}}

    # Get secrets name
    secrets_name=$(just get-secrets-name {{project_name}} {{environment}})

    # Always install/update collections and roles
    echo "Installing/updating Ansible collections and roles..."
    ansible-galaxy collection install -r requirements.yml -p ./collections
    ansible-galaxy role install -r requirements.yml -p ./roles

    # Run only wordpress role
    ansible-playbook \
        -i inventory.ini \
        -e "env={{environment}}" \
        -e "hostname={{hostname}}" \
        -e "secrets_name=${secrets_name}" \
        --tags wordpress \
        playbook.yml {{args}}

# Run only the nginx role
[group: "Ansible"]
ansible-nginx \
    hostname=default-hostname \
    project_name=default-project_name \
    environment=default-environment \
    *args:
    #!/usr/bin/env bash
    set -e
    cd {{ansible-dir}}

    # Get secrets name
    secrets_name=$(just get-secrets-name {{project_name}} {{environment}})

    # Always install/update collections and roles
    echo "Installing/updating Ansible collections and roles..."
    ansible-galaxy collection install -r requirements.yml -p ./collections
    ansible-galaxy role install -r requirements.yml -p ./roles

    # Run only nginx role
    ansible-playbook \
        -i inventory.ini \
        -e "env={{environment}}" \
        -e "hostname={{hostname}}" \
        -e "secrets_name=${secrets_name}" \
        --tags nginx \
        playbook.yml {{args}}

clean:
    #!/usr/bin/env bash
    rm -rf terraform/tfplan terraform/tfplan.txt \
    terraform/.terraform terraform/.terraform.lock.hcl \

validate:
    #!/usr/bin/env bash
    echo "Validating Terraform files..."
    cd {{terraform-dir}}
    terraform validate
    echo "Validating Ansible files..."
    cd ../{{ansible-dir}}
    ansible-playbook -i inventory.ini playbook.yml --syntax-check
    echo "Validation complete"
