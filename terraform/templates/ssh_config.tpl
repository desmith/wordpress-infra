Host ${hostname} iskconorg_${env} iorg${env}
    HostName ${instance_ip}
    User ec2-user
    IdentityFile ~/.ssh/icg/${key_pair_name}.pem
    ProxyJump bastion-ic

