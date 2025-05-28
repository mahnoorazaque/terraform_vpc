# Terraform AWS VPC Setup

This Terraform project sets up:

- A VPC with one public and one private subnet
- An Internet Gateway for public subnet
- A NAT Gateway for private subnet internet access
- EC2 instances in both subnets
- Security groups for access control

## Requirements

- [Terraform](https://www.terraform.io/downloads)
- AWS CLI configured with appropriate credentials

## Usage

git clone https://github.com/your-username/terraform-vpc-project.git
cd terraform-vpc-project

terraform init
terraform plan
terraform apply
