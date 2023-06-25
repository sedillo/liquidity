data "aws_secretsmanager_secret" "db_password" {
  name = "AuroraMasterPassword"
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}