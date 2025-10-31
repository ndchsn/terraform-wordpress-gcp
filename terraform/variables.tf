variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "asia-southeast2"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "asia-southeast2-a"
}

variable "mysql_root_password" {
  description = "MySQL root password"
  type        = string
  default     = "rootpassword123"
  sensitive   = true
}

variable "mysql_database" {
  description = "MySQL database name"
  type        = string
  default     = "wordpress"
}

variable "mysql_user" {
  description = "MySQL user"
  type        = string
  default     = "wpuser"
}

variable "mysql_password" {
  description = "MySQL user password"
  type        = string
  default     = "wppassword123"
  sensitive   = true
}