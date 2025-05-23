resource "aws_db_instance" "TwoTierDB" {
  allocated_storage           = 5
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = "5.7"
  instance_class              = "db.t3.micro"
  db_subnet_group_name        = aws_db_subnet_group.two_tier_db_sub.id
  vpc_security_group_ids      = [aws_security_group.TwoTierDBSecurityGroup.id]
  parameter_group_name        = "default.mysql5.7"
  db_name                     = "two_tier_db1"
  username                    = "admin"
  password                    = "password"
  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
  backup_retention_period     = 35
  backup_window               = "22:00-23:00"
  maintenance_window          = "Sat:00:00-Sat:03:00"
  multi_az                    = false
  skip_final_snapshot         = true

  tags = {
    Name = "TwoTierDB"
  }
}
