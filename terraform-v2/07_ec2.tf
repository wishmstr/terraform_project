################### Searching for EC2 instance Image

data "aws_ami" "ubuntu" {
  most_recent = "true"

  # Filter results for AMI
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  # Only hvm virtualization type
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # ID of the publisher Canonical we want to use
  owners = ["099720109477"]
}

################### Creating EC 2 instance
resource "aws_instance" "my_web" {
  # Count the number of instances we want from the settings file
  count = var.settings.web_app.count

  # Select the AMI to use
  ami = data.aws_ami.ubuntu.id

  # Set the instance type
  instance_type = var.settings.web_app.instance_type

  # Subnet ID for the EC2 instance
  subnet_id = aws_subnet.my_public_subnet[count.index].id

  # Key pair to use with instance
  key_name = aws_key_pair.my_kp.key_name

  # Apply Security Group
  vpc_security_group_ids = [aws_security_group.my_web_sg.id]

  # Tags
  tags = {
    Name = "my_web_${count.index}"
  }
}