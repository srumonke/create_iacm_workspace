resource "harness_platform_workspace" "dev" {
  name                    = "dev-workspace"
  identifier              = "dev_workspace"
  org_id                  = var.org_id
  project_id              = var.project_id
  provisioner_type        = "terraform"
  provisioner_version     = "1.5.7"
  repository              = "create_iacm_workspace"
  repository_branch       = "main"
  repository_path         = ""
  repository_connector    = var.github_connector_id
  provider_connector      = var.github_connector_id
  cost_estimation_enabled = false

  terraform_variable {
    key        = "workspace_name"
    value      = "dev-workspace"
    value_type = "string"
  }

  terraform_variable {
    key        = "environment"
    value      = "dev"
    value_type = "string"
  }
}
