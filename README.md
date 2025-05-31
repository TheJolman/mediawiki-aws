# MediaWiki on AWS

A complete Terraform configuration for deploying MediaWiki on AWS using ECS Fargate, RDS MySQL, and Application Load Balancer.

## Architecture

This deployment creates:
- **VPC** with public/private subnets across multiple AZs
- **ECS Fargate** cluster running MediaWiki containers
- **RDS MySQL** database in private subnets
- **Application Load Balancer** for high availability
- **EFS** for persistent file storage
- **S3** for configuration and media storage
- **CloudWatch** logging and monitoring
- **GuardDuty** security monitoring (optional)

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Docker Hub account (if using custom MediaWiki image)

## Quick Start

1. **Clone and navigate to the project:**
   ```bash
   git clone <your-repo-url>
   cd mediawiki-aws/mediawiki-aws
   ```

2. **Create your configuration file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit `terraform.tfvars` with your values:**
   ```hcl
   db_username = "admin"
   db_password = "your-secure-password"
   db_name     = "mediawiki"
   ```

4. **Deploy the infrastructure:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

5. **Get the MediaWiki URL:**
   ```bash
   terraform output mediawiki_url
   ```

6. **Complete MediaWiki setup:**
   - Visit the URL from step 5
   - Follow the MediaWiki installation wizard
   - Download the `LocalSettings.php` file when prompted

7. **Upload configuration to S3:**
   ```bash
   aws s3 cp LocalSettings.php s3://$(terraform output -raw s3_bucket_name)/LocalSettings.php
   ```

8. **Restart the ECS service:**
   ```bash
   aws ecs update-service --cluster $(terraform output -raw ecs_cluster_name) \
     --service $(terraform output -raw ecs_service_name) --force-new-deployment
   ```

## Configuration Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `aws_region` | AWS region for deployment | `us-west-1` | No |
| `project_name` | Name prefix for all resources | `mediawiki` | No |
| `environment` | Environment name (dev/staging/prod) | `dev` | No |
| `db_username` | Database admin username | - | **Yes** |
| `db_password` | Database admin password | - | **Yes** |
| `db_name` | Database name | `mediawiki` | No |
| `mediawiki_image` | Docker image for MediaWiki | `thejolman/mediawiki-aws:latest` | No |
| `config_file` | MediaWiki config file name | `LocalSettings.php` | No |
| `logo_file` | MediaWiki logo file name | `wiki.png` | No |
| `availability_zone_count` | Number of AZs to use | `2` | No |
| `enable_deletion_protection` | Enable RDS deletion protection | `false` | No |
| `skip_final_snapshot` | Skip snapshot creation when deleting DB | `true` | No |
| `enable_guardduty` | Enable GuardDuty monitoring | `false` | No |

## Example terraform.tfvars

```hcl
# Required variables
db_username = "wikiuser"
db_password = "MySecurePassword123!"

# Optional customizations
project_name = "my-wiki"
environment = "production"
aws_region = "us-east-1"
availability_zone_count = 3
enable_deletion_protection = true
skip_final_snapshot = false
enable_guardduty = true
```

## Post-Deployment Configuration

### Uploading Custom Logo
```bash
aws s3 cp your-logo.png s3://$(terraform output -raw s3_bucket_name)/wiki.png
```

### Accessing Logs
```bash
aws logs describe-log-groups --log-group-name-prefix "/ecs/mediawiki"
```

### Database Access
The RDS instance is in private subnets. To access:
1. Use AWS Systems Manager Session Manager
2. Create a bastion host in public subnet
3. Use RDS Proxy (not included in this configuration)

## Security Features

- VPC with private subnets for database
- Security groups with minimal required access
- ECS tasks run in private subnets
- ALB provides public access point
- Optional GuardDuty threat detection
- IAM roles with least privilege access

## Monitoring

- CloudWatch logs for ECS tasks
- RDS performance insights
- ALB access logs
- Optional GuardDuty findings

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Warning:** This will permanently delete all data including the database and S3 bucket contents.

## Troubleshooting

### Common Issues

1. **Service fails to start:**
   - Check CloudWatch logs: `aws logs tail /ecs/mediawiki-app --follow`
   - Verify S3 bucket has LocalSettings.php

2. **Database connection errors:**
   - Ensure security groups allow ECS → RDS communication
   - Verify database credentials in terraform.tfvars

3. **ALB health check failures:**
   - MediaWiki needs LocalSettings.php to pass health checks
   - Check ECS task health in AWS console

### Useful Commands

```bash
# View ECS service status
aws ecs describe-services --cluster $(terraform output -raw ecs_cluster_name) \
  --services $(terraform output -raw ecs_service_name)

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw target_group_arn)

# View recent logs
aws logs tail /ecs/mediawiki-app --since 1h
```
