terraform {
  backend "gcs" {}
}

provider google {
  project = var.project_id[terraform.workspace]
}

# -----------------------------------------------------------------------------
# locals
# -----------------------------------------------------------------------------
locals {
  project_id   = var.project_id[terraform.workspace]
  project_name = "Bitwyre Production"

  instance_name         = "vm-jenkins-${local.project_id}-${terraform.workspace}"
  instance_machine_type = "e2-standard-4"
  instance_tags         = ["jenkins", "private"]

  instance_boot_disk_init_params = {
    type  = "pd-standard"
    image = "ubuntu-minimal-2004-lts"
  }

  instance_network_interface = {
    subnetwork = data.terraform_remote_state.vpc_state.outputs.subnets_names[0]
    nat_ip     = data.google_compute_address.jenkins_public_ip.address
  }


  firewall_network     = data.terraform_remote_state.vpc_state.outputs.network_name
  firewall_target_tags = ["jenkins"]
  
  external_address_name   = "external-address-jenkins-${local.project_id}-${terraform.workspace}"
  external_address_region = data.terraform_remote_state.vpc_state.outputs.subnets_regions[0]


}
# -----------------------------------------------------------------------------
# PROVISION VM AS jenkins INSTANCE
# -----------------------------------------------------------------------------
data google_compute_address jenkins_public_ip {
  name   = local.external_address_name
  region = local.external_address_region
}

resource google_compute_instance vault {
  project      = local.project_id
  name         = local.instance_name
  machine_type = local.instance_machine_type
  zone         = "${data.terraform_remote_state.vpc_state.outputs.subnets_regions[0]}-a"

  tags = local.instance_tags

  boot_disk {
    initialize_params {
      type  = local.instance_boot_disk_init_params["type"]
      image = local.instance_boot_disk_init_params["image"]
    }
  }

  network_interface {
    subnetwork         = local.instance_network_interface["subnetwork"]
    subnetwork_project = local.project_id
    access_config {
      nat_ip = local.instance_network_interface["nat_ip"]
    }
  }

  
}

