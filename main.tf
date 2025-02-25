# Original document located at: https://medium.com/strategio/using-terraform-to-create-aws-vpc-ec2-and-rds-instances-c7f3aa416133
# Updated and adapted by: Jason Franklin 09/01/24


################### Terraform definition settings

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "4.0.0"
        }
    }
    # Required version of Terraform
    required_version = ">= 1.1.5"
}

provider "aws" {
    region = var.aws_region
}

data "aws_availability_zones" "available" {
    state = "available"
}

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

################### Create Security Group for EC2 Instances
resource "aws_security_group" "my_web_sg" {
    # Basic Details of SG
    name = "my_web_sg"
    description = "Security Group for tutorial web services"

    # Put SG in the VPC
    vpc_id = aws_vpc.my_vpc.id

    # Allow HTTP Traffic on web app_server
    ingress {
        description = "Allow all traffic through HTTP"
        from_port = "80"
        to_port = "80"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow SSH
    ingress{
        description = "Allow SSH from my computer"
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["${var.my_ip}/32"]
    }
    # Allow all outbound traffic
    egress {
        description = "Allow all outbound traffic"
        from_port = "0"
        to_port = "0"
        protocol = "-1"
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
    name = "my_db_sg"
    description = "Security Group for tutorial database"

    # Attach it to our VPC
    vpc_id = aws_vpc.my_vpc.id

    # DB only accessable internal with no outward facing ports
    ingress {
        description = "Allow MySQL traffic from only the web SG"
        from_port = "3306"
        to_port = "3306"
        protocol = "tcp"
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
    name = "my_db_subnet_group"
    description = "DB subnet group for tutorial"

    # db subnet needs 2 or more subnets, we are going to loop through
    # our private subnets and add them to the db subnet group
    subnet_ids = [for subnet in aws_subnet.my_private_subnet : subnet.id]
}

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
# ################### Create public key pair
# resource "tls_private_key" "ssh_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

################### Create public key pair
resource "aws_key_pair" "my_kp" {
    # Name the key pair
    key_name = "my_kp"

    # Use key pair in directory
    public_key = file("my_kp.pub")
}

################### Searching for EC2 instance Image

data "aws_ami" "ubuntu" {
    most_recent = "true"

    # Filter results for AMI
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    # Only hvm virtualization type
    filter {
        name = "virtualization-type"
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