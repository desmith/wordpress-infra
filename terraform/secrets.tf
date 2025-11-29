resource "aws_secretsmanager_secret" "db_secrets" {
  name        = var.secrets_name
  description = "Database secrets for WordPress"
}

resource "random_password" "db_password" {
  length  = 16
  special = false
}

resource "random_password" "wp_admin_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret_version" "db_secrets" {
  secret_id = aws_secretsmanager_secret.db_secrets.id
  secret_string = jsonencode({
    dbname            = var.db_name
    username          = var.db_username
    password          = random_password.db_password.result
    wp_admin_user     = var.wp_admin_user
    wp_admin_password = random_password.wp_admin_password.result
    wp_admin_email    = var.wp_admin_email
  })
}






