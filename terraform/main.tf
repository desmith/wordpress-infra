# Local value to construct subdomain name
locals {
  vpc_id = data.aws_subnet.webserver.vpc_id
  ssh_cidr = "${chomp(data.http.current_ip.response_body)}/32"
  target_group_name = replace(replace("${var.env}-${var.project_name}-tg", ".", ""), " ", "")
  listener_rule_name = replace(replace("${var.project_name}-${var.env}", ".", "-"), " ", "")
  listener_rule_priority = tonumber(data.external.listener_rules.result.output)

}

# Generate Ansible inventory file
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    instance_ip   = aws_eip.webserver_eip.public_ip
    key_pair_name = var.key_pair_name
    env           = var.env
    hostname      = var.hostname
  })
  filename = "${path.module}/../ansible/inventory.ini"
}


# Generate SSH config file
resource "local_file" "ssh_config" {
  content = templatefile("${path.module}/templates/ssh_config.tpl", {
    hostname     = var.hostname
    instance_ip   = aws_eip.webserver_eip.private_ip
    key_pair_name = var.key_pair_name
    env           = var.env
  })
  filename             = "${data.external.home_dir.result.home}/.ssh/conf.d/icg-${var.env}.ssh"
  file_permission      = "0644"
  directory_permission = "0755"
}
