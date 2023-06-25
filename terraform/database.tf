resource "aws_db_subnet_group" "main" {
  name       = "liquidity_sg"
  subnet_ids = aws_subnet.main[*].id

  tags = {
    Name = "liquidity_sg"
  }
}

resource "aws_db_instance" "default" {
  db_name          = "rrp"
  identifier       = "liquidity-db"

  allocated_storage    = 5
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin" # update as necessary
  password             = data.aws_secretsmanager_secret_version.db_password.secret_string
  skip_final_snapshot  = true

  multi_az = false
  apply_immediately = true
  db_subnet_group_name = aws_db_subnet_group.main.name

  tags = {
    Name = "liquidity"
  }
}
