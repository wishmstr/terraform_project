################### Create VPC and name it
resource "aws_vpc" "my_vpc" {
  # Link VPC to CIDR block variable
  cidr_block = var.vpc_cidr_block
  # DNS host names enabled
  enable_dns_hostnames = true

  # Adding tag to the VPC
  tags = {
    Name = "my_vpc"
  }
}

################### Create Internet Gateway and attach it to VPC
resource "aws_internet_gateway" "my_igw" {
  # Attaching this gateway to our VPC
  vpc_id = aws_vpc.my_vpc.id

  # Adding Tag to this gateway
  tags = {
    Name = "my_igw"
  }
}

################### Create Public Subnets

resource "aws_subnet" "my_public_subnet" {
  # Referencing subnets_count variable and getting the public number
  count = var.subnet_count.public

  # Put the subnet into the "my_vpc" VPC
  vpc_id = aws_vpc.my_vpc.id

  # Grab the CIDR block from the list
  cidr_block = var.public_subnet_cidr_blocks[count.index]

  # Get AZ based on variable list
  availability_zone = data.aws_availability_zones.available.names[count.index]

  #Tags
  tags = {
    Name = "my_public_subnet_${count.index}"
  }
}

################### Create Private Subnets

resource "aws_subnet" "my_private_subnet" {
  # Referencing subnets_count variable and getting the private number
  count = var.subnet_count.private

  # Put the subnet into the my_vpc VPC
  vpc_id = aws_vpc.my_vpc.id

  # Grab the CIDR block from the list
  cidr_block = var.private_subnet_cidr_blocks[count.index]

  # Get AZ based on variable list
  availability_zone = data.aws_availability_zones.available.names[count.index]

  #Tags
  tags = {
    Name = "my_private_subnet_${count.index}"
  }
}

################### Create Routing Table

resource "aws_route_table" "my_public_rt" {
  # Put the route table in the my_vpc VPC
  vpc_id = aws_vpc.my_vpc.id

  # Needs to access internet, so use 0.0.0.0/0 and target the gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

################### Add public subnets to the public route table
resource "aws_route_table_association" "public" {

  # Count the number of subnets we want to associate with this route
  count = var.subnet_count.public

  # Associating with the public route table
  route_table_id = aws_route_table.my_public_rt.id

  # Subnet ID
  subnet_id = aws_subnet.my_public_subnet[count.index].id
}

################### Create private route table
resource "aws_route_table" "my_private_rt" {
  # Put the route table in the my_vpc VPC
  vpc_id = aws_vpc.my_vpc.id

  # No external routes needed since this is a private network
}

################### Add private subnets to private routing table
resource "aws_route_table_association" "private" {

  # Count the number of private subnets
  count = var.subnet_count.private

  # Associate subnets with the private routing table
  route_table_id = aws_route_table.my_private_rt.id

  # Give all Subnets an ID
  subnet_id = aws_subnet.my_private_subnet[0].id
}

################### Create Elastic IP for each EC2 Instance
resource "aws_eip" "my_web_eip" {

  # Number of Elastic IPs to create
  count = var.settings.web_app.count

  # Instance to map to Elastic IP
  instance = aws_instance.my_web[count.index].id

  # Have the Elastic IP be within the VPC
  #vpc = true

  # Tags
  tags = {
    Name = "my_web_eip_${count.index}"
  }
}

################### Create public key pair
resource "aws_key_pair" "my_kp" {
  # Name the key pair
  key_name = "my_kp"

  # Use key pair in directory
  public_key = file("my_kp.pub")
}