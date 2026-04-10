# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is the **application/definition repository** for Harness IaCM workspaces. Developers define workspaces in `workspace.yaml`, and Terraform in a separate repository ([terraform-complex-structure](https://github.com/srumonke/terraform-complex-structure)) reads this YAML to provision the workspaces.

## Architecture

1. Developer pushes changes to `workspace.yaml` on `main`
2. Webhook trigger fires the `iacm_workspace_provision_iacm` pipeline in Harness (org: `TwilioCentraOrg`, project: `Twilioinfra`)
3. The pipeline runs an IACM stage (`init` → `plan` → `apply`) against `bootstrapworkspace3`
4. `bootstrapworkspace3` points to `terraform-complex-structure` repo, path `modules/common/application_workspace_create`
5. Terraform fetches `workspace.yaml` via HTTP from `raw.githubusercontent.com` (no repo cloning needed)
6. `harness_platform_workspace` resources are created/updated via `yamldecode` + `for_each`

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

## Harness Resources

- **Pipeline**: `iacm_workspace_provision_iacm` (org: `TwilioCentraOrg`, project: `Twilioinfra`)
- **Bootstrap Workspace**: `bootstrapworkspace3` → `terraform-complex-structure` repo, path `modules/common/application_workspace_create`
- **Webhook Trigger**: `workspace_yaml_push_trigger` — fires on push to `main`
- **GitHub Connector**: `twilio_connector`

## Shared Variables

The following values are configured in the Terraform repo (not here):
- `workspace_repo_raw_url`: Raw GitHub URL for this repo (default: `https://raw.githubusercontent.com/srumonke/create_iacm_workspace`)
- `workspace_repo_branch`: Branch to fetch workspace.yaml from (default: `main`)
- `org_id`: Organization identifier (default: `default`)
- `project_id`: Project identifier (default: `Twilio`)
- `github_connector_id`: GitHub connector for repos (default: `twilio_connector`)
- Harness provider credentials (`HARNESS_ENDPOINT`, `HARNESS_ACCOUNT_ID`, `HARNESS_PLATFORM_API_KEY`): Set as environment variables on `bootstrapworkspace3`
