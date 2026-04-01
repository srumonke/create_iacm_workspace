# IaCM Workspace Provisioning

This repository uses the Harness Terraform provider to create IaCM workspaces in Harness. When new workspace definitions are pushed to `main`, a Harness pipeline automatically runs `terraform init`, `plan`, and `apply` via a bootstrap IaCM workspace.

## How It Works

1. A **bootstrap IaCM workspace** in Harness points to this repo
2. A **webhook trigger** fires on pushes to `main`
3. The pipeline runs `init` / `plan` / `apply` on the bootstrap workspace
4. Terraform uses the Harness provider to create/update IaCM workspaces

## Adding a New Workspace

1. Create a new `.tf` file at the repo root (e.g., `my_workspace.tf`):

   ```hcl
   resource "harness_platform_workspace" "my_workspace" {
     name                 = "my-workspace"
     identifier           = "my_workspace"
     org_id               = var.org_id
     project_id           = var.project_id
     provisioner_type     = "terraform"
     provisioner_version  = "1.5.7"
     repository           = "my-infra-repo"
     repository_branch    = "main"
     repository_path      = "terraform/"
     repository_connector = var.github_connector_id
     provider_connector   = var.github_connector_id

     terraform_variable {
       key        = "env"
       value      = "dev"
       value_type = "string"
     }
   }
   ```

2. Commit and push to `main`:
   ```bash
   git add my_workspace.tf
   git commit -m "Add my-workspace"
   git push origin main
   ```

3. The Harness pipeline `iacm_workspace_provision` triggers automatically and creates the workspace.

## File Structure

```
├── provider.tf            # Harness Terraform provider config
├── variables.tf           # Shared variables (org, project, connector IDs)
├── example_workspace.tf   # Example workspace definition
└── <your_workspace>.tf    # Add new workspace definitions here
```
