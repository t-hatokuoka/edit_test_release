terraform {
  backend "gcs" {
    bucket = "dev-infra-terraform"
    prefix = "test"
  }
}

variable "image_version" {
  default = "build-HEAD"
}

variable "private_key" {
  default = "id_rsa"
}

variable "public_key" {
  default = "id_rsa.pub"
}

locals {
  system = "test"

  ip_addresses = {
    dev   = ["182.22.23.167"]
  }
}

module "test-hatokuoka-container" {
  source = "modules/openstack-swift-container"

  environment = "${terraform.workspace}"
  system      = "${local.system}"
}

module "hatokuoka" {
  source = "modules/openstack-storage-instance"

  environment = "${terraform.workspace}"
  system      = "${local.system}"
  component   = "hatokuoka"
  replica     = "${length(local.ip_addresses[terraform.workspace])}"

  image_name         = "test-hatokuoka-${var.image_version}"
  flavor_name        = "m1.small"
  security_groups    = ["default"]
  availability_zones = ["A-ynwp-bbt-ba2-pi"]
  scheduler_policies = ["anti-affinity"]
  private_key        = "${var.private_key}"
  public_key         = "${var.public_key}"

  network_name         = "ynwp-bbt-ba2-194-vm"
  network_subnet_name  = "ynwp-bbt-ba2-194-vm"
  network_ip_addresses = "${local.ip_addresses[terraform.workspace]}"

  infra_init_config    = "../infra-init/${terraform.workspace}/config.env"

  block_storage_size = 5
}
