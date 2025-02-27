################### Create Security Group for EC2 Instances
resource "aws_security_group" "my_web_sg" {
  # Basic Details of SG
  name        = "my_web_sg"
  description = "Security Group for tutorial web services"

  # Put SG in the VPC
  vpc_id = aws_vpc.my_vpc.id

  # Allow HTTP Traffic on web app_server
  ingress {
    description = "Allow all traffic through HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH
  ingress {
    description = "Allow SSH from my computer"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["${var.terraform_ip}/32"]
  }
  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Always add a tag!
  tags = {
    Name = "my_web_sg"
  }
}

################### SG for db server
resource "aws_security_group" "my_db_sg" {
  # Basic info
  name        = "my_db_sg"
  description = "Security Group for tutorial database"

  # Attach it to our VPC
  vpc_id = aws_vpc.my_vpc.id

  # DB only accessable internal with no outward facing ports
  ingress {
    description     = "Allow MySQL traffic from only the web SG"
    from_port       = "3306"
    to_port         = "3306"
    protocol        = "tcp"
    security_groups = [aws_security_group.my_web_sg.id]
  }

  # Tag it
  tags = {
    Name = "my_db_sg"
  }
}

################### Create an RDS subnet
resource "aws_db_subnet_group" "my_db_subnet_group" {
  # Basics
  name        = "my_db_subnet_group"
  description = "DB subnet group for tutorial"

  # db subnet needs 2 or more subnets, we are going to loop through
  # our private subnets and add them to the db subnet group
  subnet_ids = [for subnet in aws_subnet.my_private_subnet : subnet.id]
}
