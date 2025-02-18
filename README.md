Terraform Project Overview

This project created an AWS EC2 instance and a MySQL instance.  The reason to include your personal IP address in the secrets.tfvars file is the Security Group sets up a rule to only allow SSH from your IP address only.

1) Run the keygen script to generate your public and private keys.  This will enable you to connect to the EC2 instance after it is created.
2) Edit the secrets.tfvars file and enter your public address.  This is to allow your workstaiton through the firewall.
3) Run Terraform init/plan/apply making sure to use the flag of --var-file="secrets.tfvars" so the script doesn't prompt you for parameters in the secrets.tfvars file.
4) After the infrastructure is completed, run the connect script to ssh into the EC2 instance that is created.
