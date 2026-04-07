# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is the **application/definition repository** for Harness IaCM workspaces. Developers define workspaces in `workspace.yaml`, and Terraform in a separate repository ([terraform-complex-structure](https://github.com/srumonke/terraform-complex-structure)) reads this YAML to provision the workspaces.

## Architecture

```
[This repo: workspace.yaml] --cloned by pipeline--> [Terraform repo: terraform-complex-structure]
                                                          |
                                                    yamldecode + for_each
                                                          |
                                                    harness_platform_workspace resources
```

- **This repo**: Contains only `workspace.yaml` — the single source of truth for workspace definitions
- **Terraform repo** (`terraform-complex-structure`): Contains all Terraform code (provider config, modules, variables, `for_each` logic)
- **Harness pipeline**: Clones both repos, runs `terraform init/plan/apply` from the Terraform repo
- **Trigger**: Webhook fires on pushes to `main` in this repo

## workspace.yaml Structure

```yaml
workspaces:
  <key>:                        # Unique key used by Terraform for_each
    name: <display-name>        # Kebab-case display name
    identifier: <id>            # Snake_case unique identifier
    provisioner_type: terraform
    provisioner_version: "1.5.7"
    repository: <repo-name>     # GitHub repo this workspace manages
    repository_branch: main
    repository_path: ""         # Subdirectory (empty for root)
    cost_estimation_enabled: false
    terraform_variables:
      <var_name>:
        value: <value>
        value_type: string
```

## Naming Conventions

- Workspace keys in YAML: snake_case (e.g., `dev`, `sk`, `ah`)
- `identifier` field: snake_case (e.g., `dev_workspace`)
- `name` field: kebab-case (e.g., `dev-workspace`)

## Workflow

1. Edit `workspace.yaml` to add/modify/remove workspace entries
2. Validate YAML syntax before committing
3. Commit and push to `main`
4. The Harness pipeline automatically provisions changes

## Validation

No build or test commands exist in this repo. To validate changes:
```bash
# Check YAML syntax (requires python3)
python3 -c "import yaml; yaml.safe_load(open('workspace.yaml'))"
```

## Shared Variables

The following values are configured in the Terraform repo (not here):
- `org_id`: Organization identifier (default: "default")
- `project_id`: Project identifier (default: "Twilio")
- `github_connector_id`: GitHub connector for repos (default: "twilio_connector")
- `harness_account_id`, `harness_api_key`: Set in the IaCM workspace environment
