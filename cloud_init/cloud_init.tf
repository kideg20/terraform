locals {

  ##########
  # RUNCMD #
  ##########
  run_cmd = templatefile("${path.module}/templates/cloud-config-run-cmd.yml.tftpl", {
    runcmd        = local.runcmd_files
    }
  )
  runcmd_files_auto = flatten([
      for files in local.combine_write_files : [
        endswith(files.remote_path,".auto.sh") ? files.remote_path : ""
      ]
    ])
  runcmd_files = concat(
    local.runcmd_files_auto,
    local.runcmd_execute_files
  )
  run_cmd_combined = local.runcmd_enabled ? format("runcmd: %s\n  %s", local.run_cmd, indent(2,local.runcmd_manual_config)) : ""
  
  ###############
  # USER GROUPS #
  ###############
  user_groups = templatefile("${path.module}/templates/cloud-config-user-groups.yml.tftpl", {
    users  = local.cloud_config_users
    groups = local.cloud_config_groups
    }
  )

  ###############
  # Combine all #
  ###############
  #cloud_config_combined = format("%s\n%s\n%s", local.write_files, local.run_cmd_combined,local.user_groups)

}
########################################################## CLOUD CONFIG
data "cloudinit_config" "user_data" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = local.user_groups
  }
  part {
    content_type = "text/cloud-config"
    content      = local.write_files
  }
  part {
    content_type = "text/cloud-config"
    content      = local.run_cmd_combined
  }
  part {
    content_type = "text/cloud-config"
    content      = local.cloud_config_manual_config
  }

}
########################################################## END CLOUD CONFIG

output "combined_write_files" {
  value     = local.combine_write_files
  sensitive = true
}

output "cloudinit_config_rendered" {
  value     = data.cloudinit_config.user_data.rendered
  sensitive = true
}

output "exec" {
  value = flatten([
    for files in local.combine_write_files : [
      files.remote_path
    ]
  ])
  sensitive = true
}
