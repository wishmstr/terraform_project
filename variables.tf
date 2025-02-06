# Variables for main.tf

# Region for VPC
variable "aws_region" {
    default = "us-east-2"
}

# CIDR block info 
variable "vpc_cidr_block" {
    description = "CIDR block for VPC"
    type = string
    default = "10.0.0.0/16"
}

# Number of public and private subnets
variable "subnet_count" {
    description = "Number of subnets"
    type = map(number)
    default = {
        public = 1,
        private = 2
    }
}

# EC2 and RDS instances
variable "settings" {
    description = "Configuration settings"
    type = map(any)
    default = {
        "database" = {
            allocated_storage = 10 # storage in GB
            engine = "mysql" # engine type
            engine_version = "8.0.37" # mySQL version
            instance_class = "db.t3.micro" # rds instance type
            db_name = "tutorial" # db name
            skip_final_snapshot = true
        },
        "web_app" = {
            count = 1 # Number of EC2 instances to make
            instance_type = "t2.micro" # EC2 instance type
        }
    }
}

# Public subnet CIDR blocks
variable "public_subnet_cidr_blocks" {
    description = "Available CIDR blocks for the public subnets"
    type = list(string)
    default = [
        "10.0.1.0/24",
        "10.0.2.0/24",
        "10.0.3.0/24",
        "10.0.4.0/24"
    ]
}

# Private subnet CIDR blocks
variable "private_subnet_cidr_blocks" {
    description = "Available CIDR blocks for private subnets"
    type = list(string)
    default = [
        "10.0.101.0/24",
        "10.0.102.0/24",
        "10.0.103.0/24",
        "10.0.104.0/24",
    ]
}

variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1", "us-east-2"]
  description = "A list of availability zones where resources will be deployed"
}

# My IP address
variable "my_ip" {
    description = "Your IP address"
    type = string
    sensitive = true
}

# Database root user
variable "db_username" {
    description = "Database master user"
    type = string
    sensitive = true
}

# Database root user password
variable "db_password" {
    description = "Database master password"
    type = string
    sensitive = true
}