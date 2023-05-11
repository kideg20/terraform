### Write files 
locals {

    cloud_config_write_files = lookup(var.cloud_config, "write_files", {})
    write_files_from_folder = lookup(local.cloud_config_write_files, "from_folder", [])
    write_files_from_file = lookup(local.cloud_config_write_files, "from_file", [])
    write_files_from_vault_path_enabled = local.write_files_from_vault_path != [] ? true : false
    write_files_from_vault_path = lookup(local.cloud_config_write_files, "from_vault_path", [])
    write_files_from_vault_key_enabled = local.write_files_from_vault_key != [] ? true : false
    write_files_from_vault_key = lookup(local.cloud_config_write_files, "from_vault_key", [])
    write_files_from_variable = lookup(local.cloud_config_write_files, "from_variable", "")
    write_files_from_template_file = lookup(local.cloud_config_write_files, "from_template_file", [])
    write_files_from_template_folder = lookup(local.cloud_config_write_files, "from_template_folder", [])
}

### Run CMD
locals {

    cloud_config_runcmd = lookup(var.cloud_config, "runcmd", {})
    runcmd_enabled = local.cloud_config_runcmd != {} ? true : false
    runcmd_execute_files = lookup(local.cloud_config_runcmd, "execute_files", [])
    runcmd_manual_config = lookup(local.cloud_config_runcmd, "manual_config", "")

}

### Users and Groups
locals {
    cloud_config_users  = lookup(var.cloud_config, "users", {})
    cloud_config_groups = lookup(var.cloud_config, "groups", {})
}

### Manual config
locals {
    cloud_config_manual_config  = lookup(var.cloud_config, "manual_config", "")
}
