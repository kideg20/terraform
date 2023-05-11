############################
### WRITE FILES COMBINED ###
############################
locals {

  # Combine all write_files (exept from variable)
  combine_write_files = concat(
    local.user_data_write_files_from_folder,
    local.user_data_write_files_from_vault_path,
    local.user_data_write_files_from_file,
    local.user_data_write_files_from_vault_key,
    local.user_data_write_files_from_template_file,
    local.user_data_write_files_from_template_folder
  )

  generate_write_files = templatefile("${path.module}/templates/cloud-config-write-files.yml.tftpl", {
    write_files = local.combine_write_files
    }
  )

  # Combine combine_write_files with write_files_from_variable
  write_files = format("%s\n%s", local.generate_write_files, local.write_files_from_variable)

}

#############################
### WRITE FILES FROM FILE ###
#############################
locals {

  user_data_write_files_from_file = flatten([for file in local.write_files_from_file :
    [
      {
        owner       = try(file.owner, "root")
        group       = try(file.group,"root")
        permissions = try(file.permissions,"0644")
        remote_path = "${file.remote_file_path}"
        content     = file("${path.module}/${file.source_file_path}")
      }
    ]
  ])

}

output "user_data_write_files_from_file" {
  value     = local.user_data_write_files_from_file
  sensitive = true
}

###############################
### WRITE FILES FROM FOLDER ###
###############################
locals {

  user_data_write_files_from_folder = flatten([
    for folders in local.write_files_from_folder : [
      for folder in [folders.source_folder_path] : [
        for file in fileset("${path.module}", "/${folder}/*") : {
          owner       = try(folders.owner,"root")
          group       = try(folders.group,"root")
          permissions = try(folders.permissions,"0644")
          remote_path = "${folders.remote_folder_path}/${element(split("/", "${file}"), length(split("/", "${file}")) - 1)}"
          file        = "${file}"
          content     = file("${path.module}/${file}")
        }
      ]
    ]
  ])

}

output "user_data_write_files_from_folder" {
  value     = local.user_data_write_files_from_folder
  sensitive = true
}

######################################
### WRITE FILES FROM TEMPLATE FILE ###
######################################
locals {

  user_data_write_files_from_template_file = flatten([for file in local.write_files_from_template_file :
    [
      {
        owner       = try(file.owner,"root")
        group       = try(file.group,"root")
        permissions = try(file.permissions,"0644")
        remote_path = "${file.remote_file_path}"
        content     = templatefile("${path.module}/${file.source_file_path}", { template_vars = file.template_vars })
      }
    ]
  ])

}

output "user_data_write_files_from_template_file" {
  value     = local.user_data_write_files_from_template_file
  sensitive = true
}

########################################
### WRITE FILES FROM TEMPLATE FOLDER ###
########################################
locals {

  user_data_write_files_from_template_folder = flatten([
    for folders in local.write_files_from_template_folder : [
      for folder in [folders.source_folder_path] : [
        for file in fileset("${path.module}", "/${folder}/*") : {
          owner       = try(folders.owner, "root")
          group       = try(folders.group,"root")
          permissions = try(folders.permissions,"0644")
          remote_path = "${folders.remote_folder_path}/${element(split("/", "${file}"), length(split("/", "${file}")) - 1)}"
          file        = "${file}"
          content     = templatefile("${path.module}/${file}", { template_vars = folders.template_vars })
        }
      ]
    ]
  ])

}

output "user_data_write_files_from_template_folder" {
  value     = local.user_data_write_files_from_template_folder
  sensitive = true
}

###################################
### WRITE FILES FROM VAULT PATH ###
###################################
data "vault_generic_secret" "write_files_from_vault_path" {
  for_each = local.write_files_from_vault_path_enabled ? toset([for secret in local.write_files_from_vault_path : "${secret.vault_path}"]) : []
  path     = each.key
}

locals {

  user_data_write_files_from_vault_path = flatten([
    for folders in local.write_files_from_vault_path :
    flatten([
      [for filename, content in data.vault_generic_secret.write_files_from_vault_path["${folders.vault_path}"].data : 
        {
          owner       = try(folders.owner, "root")
          group       = try(folders.group,"root")
          permissions = try(folders.permissions,"0644")
          remote_path = "${folders.remote_folder_path}/${filename}"
          
          content     = content
        }
      ]
    ])
  ])

}

output "write_files_from_vault_path" {
  value     = local.user_data_write_files_from_vault_path
  sensitive = true
}

##################################
### WRITE FILES FROM VAULT KEY ###
##################################
# data "vault_generic_secret" "write_files_from_vault_key" {
#   for_each = toset([for secret in local.write_files_from_vault_key : "${secret.vault_path}"])
#   path     = each.key
# }
data "vault_generic_secret" "write_files_from_vault_key" {

  for_each = local.write_files_from_vault_key_enabled ? toset([for secret in local.write_files_from_vault_key : "${secret.vault_path}"]) : []
  path     = each.key
}

locals {

  user_data_write_files_from_vault_key = flatten([for secret in local.write_files_from_vault_key :
    {
      file        = "${secret.vault_key}"
      content     = data.vault_generic_secret.write_files_from_vault_key["${secret.vault_path}"].data["${secret.vault_key}"]
      owner       = try(secret.owner, "root")
      group       = try(secret.group,"root")
      permissions = try(secret.permissions,"0644")
      remote_path = secret.remote_file_path
    }
  ])

}

output "write_files_from_vault_key" {
  value     = local.user_data_write_files_from_vault_key
  sensitive = true
}
