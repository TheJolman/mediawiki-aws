variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "mediawiki"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "mediawiki"
}

variable "mediawiki_image" {
  description = "Docker Hub image for MediaWiki"
  type        = string
  default     = "thejolman/mediawiki-aws:latest"
}

variable "config_file" {
  description = "Name of MediaWiki configuration file"
  type        = string
  default     = "LocalSettings.php"
}

variable "logo_file" {
  description = "Name of 135x135 MediaWiki logo file"
  type        = string
  default     = "wiki.png"
}

variable "enable_deletion_protection" {
  description = "Enable RDS deletion protection"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Toggle creation of DB snapshot when deleting DB. Used with deletion protection is off"
  type        = bool
  default     = true
}

variable "enable_guardduty" {
  description = "Enable GuardDuty"
  type        = bool
  default     = false
}

variable "availability_zone_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2
}
