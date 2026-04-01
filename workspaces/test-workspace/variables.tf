variable "workspace_name" {
  description = "Name of the IaCM workspace to provision"
  type        = string
}

variable "environment" {
  description = "Target environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "tags" {
  description = "Tags to apply to the workspace resources"
  type        = map(string)
  default     = {}
}
