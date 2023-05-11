# Cloud init module
This module returns user data for cloud init  
`https://github.com/canonical/cloud-init`

### Usage:
```terraform
module "cloud_init" {
  source = "link to this module"

  cloud_config = local.cloud_config

}
```

### Examples
See docs/examples folder for examples
