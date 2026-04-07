# IaCM Workspace Definitions

This repository contains workspace definitions in `workspace.yaml` that are consumed by Terraform in the [terraform-complex-structure](https://github.com/srumonke/terraform-complex-structure) repository to provision Harness IaCM workspaces.

## How It Works

1. Developers add or update workspace entries in `workspace.yaml`
2. Changes are committed and pushed to `main`
3. A Harness pipeline webhook triggers on push to `main`
4. The pipeline clones both this repo and `terraform-complex-structure`
5. Terraform reads `workspace.yaml`, and creates/updates IaCM workspaces via `for_each`

## Adding a New Workspace

Add a new entry under `workspaces:` in `workspace.yaml`:

```yaml
workspaces:
  my_workspace:
    name: my-workspace
    identifier: my_workspace
    provisioner_type: terraform
    provisioner_version: "1.5.7"
    repository: my-infra-repo
    repository_branch: main
    repository_path: ""
    cost_estimation_enabled: false
    terraform_variables:
      environment:
        value: dev
        value_type: string
```

Then commit and push to `main`:

```bash
git add workspace.yaml
git commit -m "Add my-workspace"
git push origin main
```

## Workspace Fields

| Field | Description |
|---|---|
| `name` | Display name (kebab-case) |
| `identifier` | Unique ID within the project (snake_case) |
| `provisioner_type` | Provisioner type (e.g., `terraform`) |
| `provisioner_version` | Terraform version |
| `repository` | GitHub repo the workspace manages |
| `repository_branch` | Branch to use |
| `repository_path` | Subdirectory in the repo (empty string for root) |
| `cost_estimation_enabled` | Enable cost estimation |
| `terraform_variables` | Map of variables to pass to workspace runs |

## File Structure

```
├── workspace.yaml   # All workspace definitions
├── README.md
└── CLAUDE.md
```

## Terraform Repository

The Terraform code that reads this YAML and provisions workspaces lives in [terraform-complex-structure](https://github.com/srumonke/terraform-complex-structure).
