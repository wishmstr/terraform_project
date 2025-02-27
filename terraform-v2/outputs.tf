# Output the public IP of the web server
output "web_public_ip" {
  description = "The public IP address of the web server"

  # Grabbing it from the Elastic IP
  value = aws_eip.my_web_eip[0].public_ip

  # Waits for the Elastic IPs to be created and distributed
  depends_on = [aws_eip.my_web_eip]
}

# Output the public DNS address of the web server
output "web_public_dns" {
  description = "The public DNS address of the web server"

  # Grabbing it from the Elastic IP
  value = aws_eip.my_web_eip[0].public_dns

  # Waits for the Elastic IPs to be created and distributed
  depends_on = [aws_eip.my_web_eip]
}

# Outputs the database endpoint
output "database_endpoint" {
  description = "The endpoint of the database"
  value       = aws_db_instance.my_database.address
}

# This will output the database port
output "database_port" {
  description = "The port of the database"
  value       = aws_db_instance.my_database.port
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_lock.name
  description = "The name of the DynamoDB table"
}