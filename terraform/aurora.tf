resource "aws_rds_cluster" "main" {
  cluster_identifier      = "liquidity-aurora"
  engine                  = "aurora-postgresql"
  availability_zones      = data.aws_availability_zones.available.names
  database_name           = "mydb"
  master_username         = "foo"
  master_password         = data.aws_secretsmanager_secret_version.db_password.secret_string
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "main" {
  count              = 1
  identifier         = "liquidity-aurora-${count.index}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.t2.small"
  engine             = "aurora-postgresql"
}

