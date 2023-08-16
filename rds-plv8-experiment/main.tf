provider "aws" {
  region = "eu-central-1"
}

resource "aws_db_instance" "flwi_rds_expriment" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t3.micro"
  username             = "priceloop"
  password             = "very-secure-password"
  parameter_group_name = "default.postgres15"
  skip_final_snapshot  = true
  multi_az             = false

  tags = {
    Name = "flwi-plv8-experiment"
  }

  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.flwi_rds_expriment.id]
}

resource "aws_security_group" "flwi_rds_expriment" {
  vpc_id = "vpc-05904079eed81af92"
  name   = "flwi-rds-experiment"

  egress {
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }
}

resource "aws_security_group" "flwi_rds_expriment_proxy" {
  vpc_id = "vpc-05904079eed81af92"
  name   = "flwi-rds-experiment-proxy"

  egress {
    from_port       = 5432
    protocol        = "tcp"
    to_port         = 5432
    security_groups = [aws_security_group.flwi_rds_expriment.id]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "flwi-rds-experiment"
  subnet_ids = ["subnet-0fc507931aa85a20c", "subnet-0c4706de75aca9a94"]

  tags = {
    Name = "flwi rds experiment"
  }
}

resource "aws_secretsmanager_secret" "flwi_rds_experiment_secret" {
  name = "flwi-rds-experiment-secret"

}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.flwi_rds_experiment_secret.id
  secret_string = jsonencode(
    {
      username = "priceloop"
      password = "very-secure-password"
    }
  )
}

resource "aws_db_proxy" "example" {
  name                   = "flwi-rds-experiment"
  debug_logging          = true
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 900 // 15min
  require_tls            = false
  role_arn               = aws_iam_role.flwi_rds_experiment.arn
  vpc_security_group_ids = [aws_security_group.flwi_rds_expriment_proxy.id]
  vpc_subnet_ids         = ["subnet-0fc507931aa85a20c", "subnet-0c4706de75aca9a94"]



  auth {
    client_password_auth_type = "POSTGRES_SCRAM_SHA_256"
    description               = "example"
    iam_auth                  = "DISABLED"
    auth_scheme               = "SECRETS"
    secret_arn                = aws_secretsmanager_secret.flwi_rds_experiment_secret.arn
  }
}

resource "aws_db_proxy_default_target_group" "example" {
  db_proxy_name = aws_db_proxy.example.name

  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 80
    max_idle_connections_percent = 50
    session_pinning_filters      = ["EXCLUDE_VARIABLE_SETS"]
  }
}

resource "aws_db_proxy_target" "example" {
  db_instance_identifier = aws_db_instance.flwi_rds_expriment.identifier
  db_proxy_name          = aws_db_proxy.example.name
  target_group_name      = aws_db_proxy_default_target_group.example.name
}


resource "aws_iam_role" "flwi_rds_experiment" {
  name               = "flwi-rds-experiment-proxy"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "my_inline_policy"

    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action = [
            "*"
          ]
          Effect   = "Allow"
          Resource = ["*"]
        },
      ]
    })
  }

}
