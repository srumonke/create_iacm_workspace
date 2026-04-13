# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is an **application/definition repository** for Harness IaCM workspaces. Developers define workspaces in YAML files under the `workspaces/` folder, and Terraform in a separate repository ([terraform-complex-structure](https://github.com/srumonke/terraform-complex-structure)) reads the manifest and workspace files to provision the workspaces.

This repo is one of potentially many application repos. The Terraform repo maintains a registry of all application repos in `application_repos.yaml`.

## Architecture

1. Developer pushes changes to files in `workspaces/` on `main`
2. Webhook trigger fires the `iacm_workspace_provision_iacm` pipeline in Harness (org: `TwilioCentraOrg`, project: `Twilioinfra`)
3. The pipeline runs an IACM stage (`init` → `plan` → `apply`) against `bootstrapworkspace3`
4. `bootstrapworkspace3` points to `terraform-complex-structure` repo, path `modules/common/application_workspace_create`
5. Terraform reads `application_repos.yaml` to discover all registered application repos
6. For each repo, it fetches `workspaces/manifest.yaml` via HTTP, then fetches each workspace file listed in the manifest
7. All workspace maps are merged (namespaced as `repo_key/workspace_key`) and `harness_platform_workspace` resources are created/updated via `yamldecode` + `merge` + `for_each`

## Folder Structure

```
workspaces/
  manifest.yaml       # Lists all workspace files to load
  workspace01.yaml    # One or more workspace definitions
  workspace02.yaml
  ...
```

### manifest.yaml

```yaml
files:
  - workspace01.yaml
  - workspace02.yaml
```

When adding a new workspace file, you must also add it to `manifest.yaml`.

### Workspace File Structure

Each workspace file follows this format:

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

Workspace keys must be unique across all files within this repo (they are merged into a single map). In Terraform state, keys are namespaced as `repo_key/workspace_key` to avoid collisions across repos.

## Naming Conventions

- Workspace keys in YAML: snake_case (e.g., `dev`, `sk`, `ah`)
- `identifier` field: snake_case (e.g., `dev_workspace`)
- `name` field: kebab-case (e.g., `dev-workspace`)

## Workflow

1. Edit or create a workspace file in `workspaces/` (e.g., `workspace03.yaml`)
2. If adding a new file, add it to `workspaces/manifest.yaml`
3. Validate YAML syntax before committing
4. Commit and push to `main`
5. The Harness pipeline automatically provisions changes

## Registering a New Application Repo

To register a new application repo (like this one), add an entry to `application_repos.yaml` in the Terraform repo (`terraform-complex-structure/modules/common/application_workspace_create/application_repos.yaml`):

```yaml
repos:
  create_iacm_workspace:
    raw_url: https://raw.githubusercontent.com/srumonke/create_iacm_workspace
    branch: main
    org_id: default
    project_id: Twilio
    github_connector_id: twilio_connector
  new_repo:
    raw_url: https://raw.githubusercontent.com/srumonke/new-repo
    branch: main
    org_id: default
    project_id: AnotherProject
    github_connector_id: twilio_connector
```

The new repo must follow the same `workspaces/manifest.yaml` + workspace files structure.

## Validation

No build or test commands exist in this repo. To validate changes:
```bash
# Check all YAML files (requires python3 + pyyaml)
python3 -c "import yaml, glob; [yaml.safe_load(open(f)) for f in glob.glob('workspaces/*.yaml')]; print('OK')"
```

## Harness Resources

- **Pipeline**: `iacm_workspace_provision_iacm` (org: `TwilioCentraOrg`, project: `Twilioinfra`)
- **Bootstrap Workspace**: `bootstrapworkspace3` → `terraform-complex-structure` repo, path `modules/common/application_workspace_create`
- **Webhook Trigger**: `workspace_yaml_push_trigger` — fires on push to `main`
- **GitHub Connector**: `twilio_connector`

## Terraform Repo Configuration

The Terraform repo (`terraform-complex-structure`) manages all configuration:
- **`application_repos.yaml`**: Registry of all application repos with their `raw_url`, `branch`, `org_id`, `project_id`, and `github_connector_id`
- No Terraform variables are needed — everything is driven by `application_repos.yaml`
- Harness provider credentials (`HARNESS_ENDPOINT`, `HARNESS_ACCOUNT_ID`, `HARNESS_PLATFORM_API_KEY`): Set as environment variables on `bootstrapworkspace3`
