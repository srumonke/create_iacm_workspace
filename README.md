# IaCM Workspace Definitions

This repository contains workspace definitions in `workspace.yaml` that are provisioned as Harness IaCM workspaces automatically via a Harness pipeline.

## Architecture

```
┌─────────────────────────────┐       ┌──────────────────────────────────────┐
│  This repo                  │       │  terraform-complex-structure repo    │
│  (create_iacm_workspace)    │       │                                      │
│                             │       │  modules/common/                     │
│  workspace.yaml ─────────HTTP fetch─── application_workspace_create/      │
│                             │       │    ├── main.tf  (yamldecode+for_each)│
│                             │       │    ├── variables.tf                  │
│                             │       │    └── outputs.tf                    │
└──────────┬──────────────────┘       └──────────────────┬───────────────────┘
           │ push to main                                │
           ▼                                             │
┌──────────────────────────────────────────────────────────────────────────┐
│  Harness Pipeline: IaCM Workspace Provision IACM                        │
│  (org: default, project: Twilio)                                        │
│                                                                          │
│  Trigger: webhook on push to main (this repo)                           │
│  Workspace: bootstrapworkspace2 (points to terraform-complex-structure) │
│  Stage: IACM → init → plan → apply                                     │
└──────────────────────────────────────────────────────────────────────────┘
           │
           ▼
   Harness IaCM workspaces created/updated
```

## How It Works

1. Developers add or update workspace entries in `workspace.yaml`
2. Changes are committed and pushed to `main`
3. A webhook trigger fires the **IaCM Workspace Provision IACM** pipeline in Harness
4. The pipeline runs an IACM stage against `bootstrapworkspace2`, which points to the [terraform-complex-structure](https://github.com/srumonke/terraform-complex-structure) repo
5. Terraform fetches `workspace.yaml` from this repo via HTTP (`raw.githubusercontent.com`)
6. `harness_platform_workspace` resources are created/updated via `yamldecode` + `for_each`

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

The pipeline triggers automatically and provisions the workspace.

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

## Harness Resources

| Resource | Details |
|---|---|
| **Pipeline** | `iacm_workspace_provision_iacm` in org `default`, project `Twilio` |
| **Bootstrap Workspace** | `bootstrapworkspace2` — points to `terraform-complex-structure` repo, path `modules/common/application_workspace_create` |
| **Webhook Trigger** | `workspace_yaml_push_trigger` — fires on push to `main` in this repo |
| **GitHub Connector** | `twilio_connector` |

## Terraform Repository

The Terraform code that reads `workspace.yaml` and provisions workspaces lives in [terraform-complex-structure](https://github.com/srumonke/terraform-complex-structure) under `modules/common/application_workspace_create/`.

Key files:
- **`main.tf`** — Fetches `workspace.yaml` via HTTP, creates `harness_platform_workspace` resources with `for_each`
- **`variables.tf`** — Inputs for repo URL, branch, org_id, project_id, github_connector_id
- **`outputs.tf`** — Exposes map of created workspaces

## File Structure

```
├── workspace.yaml   # All workspace definitions (edit this)
├── README.md
└── CLAUDE.md
```
