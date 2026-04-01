# IaCM Workspace Provisioning

This repository contains Terraform configurations for Harness IaCM workspaces. When new workspace configs are pushed to the `workspaces/` directory on `main`, a Harness pipeline automatically runs `init`, `plan`, and `apply`.

## Adding a New Workspace

1. Copy the example workspace directory:
   ```bash
   cp -r workspaces/example-workspace workspaces/my-new-workspace
   ```

2. Edit the Terraform files in your new directory to define the desired infrastructure.

3. Commit and push to `main`:
   ```bash
   git add workspaces/my-new-workspace/
   git commit -m "Add my-new-workspace"
   git push origin main
   ```

4. The Harness pipeline `iacm_workspace_provision` will trigger automatically and run `terraform init`, `plan`, and `apply`.

## Directory Structure

```
workspaces/
├── example-workspace/
│   ├── main.tf         # Terraform configuration
│   └── variables.tf    # Input variables
└── <your-workspace>/
    ├── main.tf
    └── variables.tf
```
