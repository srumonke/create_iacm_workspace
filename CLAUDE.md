# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository provisions Harness IaCM (Infrastructure as Code Management) workspaces using Terraform and the Harness Terraform provider. It implements a self-provisioning pattern where:

1. A **bootstrap IaCM workspace** in Harness points to this repo
2. Changes to `main` trigger a webhook in Harness
3. A Harness pipeline runs `terraform init/plan/apply` on the bootstrap workspace
4. The Terraform code creates/updates IaCM workspaces in Harness

This enables declarative, GitOps-style management of IaCM workspace infrastructure.

## Architecture

### Self-Provisioning Pattern
- **Bootstrap workspace**: An existing IaCM workspace that monitors this repository
- **Pipeline trigger**: Webhook fires on pushes to `main` branch
- **Terraform provider**: Uses the Harness provider to manage workspace resources
- **Workspace creation**: Each `.tf` file defines a `harness_platform_workspace` resource

### Provider Configuration
The Harness provider (provider.tf) requires:
- `harness_endpoint`: API endpoint (defaults to https://app.harness.io/gateway)
- `harness_account_id`: Account identifier (required)
- `harness_api_key`: Platform API key (sensitive, required)

These are supplied via Terraform variables, typically set in the Harness IaCM workspace configuration.

## Key Commands

### Terraform Basics
```bash
# Initialize Terraform (downloads providers)
terraform init

# Validate configuration syntax
terraform validate

# Format Terraform files
terraform fmt

# Plan changes (dry-run)
terraform plan

# Apply changes (execute)
terraform apply

# Show current state
terraform show

# List resources in state
terraform state list
```

### Testing Changes Locally
```bash
# Validate syntax before pushing
terraform validate

# Format all .tf files
terraform fmt -recursive

# Plan with specific variable values
terraform plan \
  -var="harness_account_id=YOUR_ACCOUNT" \
  -var="harness_api_key=YOUR_KEY"
```

Note: Local testing requires valid Harness credentials. The actual apply runs in Harness via the bootstrap workspace.

## File Structure

```
├── provider.tf            # Harness provider configuration
├── variables.tf           # Shared variables (org_id, project_id, connectors)
├── example_workspace.tf   # Example/template workspace
├── dev_workspace.tf       # Dev workspace definition
├── sk_workspace.tf        # SK workspace definition
├── ah_workspace.tf        # AH workspace definition
└── <name>_workspace.tf    # Additional workspace definitions
```

### Naming Conventions
- Workspace files: `<identifier>_workspace.tf`
- Resource names: `harness_platform_workspace.<identifier>`
- Workspace identifiers: Use snake_case matching the Terraform resource name
- Workspace display names: Use kebab-case (e.g., "example-workspace")

## Adding a New Workspace

1. **Create a new .tf file** at the repository root following the naming pattern `<identifier>_workspace.tf`

2. **Define the workspace resource** using this template:
   ```hcl
   resource "harness_platform_workspace" "my_workspace" {
     name                    = "my-workspace"
     identifier              = "my_workspace"
     org_id                  = var.org_id
     project_id              = var.project_id
     provisioner_type        = "terraform"
     provisioner_version     = "1.5.7"
     repository              = "your-repo-name"
     repository_branch       = "main"
     repository_path         = ""  # or "terraform/" if nested
     repository_connector    = var.github_connector_id
     provider_connector      = var.github_connector_id
     cost_estimation_enabled = false

     terraform_variable {
       key        = "environment"
       value      = "dev"
       value_type = "string"
     }
   }
   ```

3. **Commit and push** to `main`:
   ```bash
   git add <identifier>_workspace.tf
   git commit -m "Add <identifier> workspace"
   git push origin main
   ```

4. **Monitor the pipeline**: The `iacm_workspace_provision` pipeline in Harness will automatically trigger and apply changes

## Important Workspace Fields

- `identifier`: Must be unique within the project, use snake_case
- `repository`: The GitHub repository the workspace will manage
- `repository_path`: Subdirectory in the repo (empty string for root)
- `repository_connector`: GitHub connector ID (use `var.github_connector_id`)
- `provider_connector`: Connector for Terraform providers (typically same as repository_connector)
- `terraform_variable`: Define variables to pass to the workspace's Terraform runs

## Modifying Existing Workspaces

1. **Edit the corresponding .tf file** with your changes
2. **Validate locally**: Run `terraform validate` and `terraform fmt`
3. **Commit and push** to `main`
4. The bootstrap workspace pipeline applies the changes automatically

## Variables

Shared variables in `variables.tf`:
- `harness_endpoint`: Harness API endpoint (default provided)
- `harness_account_id`: Required, set in workspace config
- `harness_api_key`: Required sensitive value, set in workspace config
- `org_id`: Organization identifier (default: "default")
- `project_id`: Project identifier (default: "Twilio")
- `github_connector_id`: GitHub connector for repos (default: "twilio_connector")

When adding workspaces, use `var.<variable_name>` to reference these shared values rather than hardcoding.

## Working with Git

This repository uses a GitOps model where:
- **main branch** is the source of truth
- All workspace changes must be committed to `main` to take effect
- The Harness pipeline only triggers on `main` branch pushes
- Feature branches can be used for development but won't trigger provisioning

## Troubleshooting

### Pipeline Failures
If the Harness pipeline fails after pushing:
1. Check the pipeline execution in Harness UI
2. Review Terraform plan/apply logs
3. Verify variable values are correct
4. Ensure resource identifiers are unique

### Local Validation Errors
```bash
# Check syntax errors
terraform validate

# Format issues
terraform fmt -check

# View what would change
terraform plan
```

### Resource Conflicts
- Workspace identifiers must be unique within a project
- If creating a workspace that already exists, Terraform will attempt to import or fail
- Use `terraform state list` to see existing managed resources
