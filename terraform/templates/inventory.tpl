[webservers]
iskcon.org-${env} ansible_host=${instance_ip} ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/icg/${key_pair_name}.pem
