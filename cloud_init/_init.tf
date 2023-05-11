terraform {
  required_version = "~> 1.3.7"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "~> 2.3.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.14.0"
    }
  }
}
