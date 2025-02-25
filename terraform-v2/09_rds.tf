################### Create DB instance

resource "aws_db_instance" "my_database" {
  # storage in GB, set in settings.database.allocated_storage variable
  allocated_storage = var.settings.database.allocated_storage

  # Engine we want to use
  engine = var.settings.database.engine

  # Engine version we want to use
  engine_version = var.settings.database.engine_version

  # Instance class/type
  instance_class = var.settings.database.instance_class

  # db Name
  db_name = var.settings.database.db_name

  # Master user set in the secrets file
  username = var.db_username

  # Master password, also in the secrets file
  password = var.db_password

  # Add to db subnet
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.id

  # Add to db SG
  vpc_security_group_ids = [aws_security_group.my_db_sg.id]

  # Skip final snapshot
  skip_final_snapshot = var.settings.database.skip_final_snapshot
}