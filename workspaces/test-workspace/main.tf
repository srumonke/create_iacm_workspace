terraform {
  required_version = ">= 1.0.0"
}

resource "null_resource" "workspace" {
  triggers = {
    workspace_name = var.workspace_name
    environment    = var.environment
  }

  provisioner "local-exec" {
    command = "echo 'Provisioned workspace: ${var.workspace_name} in ${var.environment}'"
  }
}

output "workspace_id" {
  value = null_resource.workspace.id
}

output "workspace_name" {
  value = var.workspace_name
}
