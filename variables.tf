variable "harness_endpoint" {
  description = "Harness API endpoint"
  type        = string
  default     = "https://app.harness.io/gateway"
}

variable "harness_account_id" {
  description = "Harness account identifier"
  type        = string
}

variable "harness_api_key" {
  description = "Harness platform API key"
  type        = string
  sensitive   = true
}

variable "org_id" {
  description = "Harness organization identifier"
  type        = string
  default     = "default"
}

variable "project_id" {
  description = "Harness project identifier"
  type        = string
  default     = "Twilio"
}

variable "github_connector_id" {
  description = "GitHub connector identifier for workspace repositories"
  type        = string
  default     = "twilio_connector"
}
