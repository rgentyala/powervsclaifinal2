resource "ibm_pi_key" "power_sshkey" {
  pi_key_name          = var.ssh_key_name
  pi_ssh_key           = var.ssh_key
  pi_cloud_instance_id = local.cloud_instance_id
}
data "ibm_pi_key" "key" {
  depends_on           = [ibm_pi_key.power_sshkey]
  pi_cloud_instance_id = local.cloud_instance_id
  pi_key_name          = var.ssh_key_name
}

resource "ibm_pi_image" "testacc_image" {
  pi_image_name       = "test_image"
  pi_cloud_instance_id = local.cloud_instance_id
  pi_image_bucket_name = var.buck_name
  pi_image_bucket_access = var.buck_access
  pi_image_access_key = var.buck_accesskey
  pi_image_secret_key = var.buck_secretkey
  pi_image_bucket_region = var.buck_region
  pi_image_bucket_file_name = var.buck_imagename
  pi_image_storage_type = var.img_storage_type
}

#data "ibm_pi_catalog_images" "catalog_images" {
#  sap                  = true
#  vtl                  = true
#pi_cloud_instance_id = local.pid
#}

#data "ibm_pi_images" "cloud_instance_images" {
#  pi_cloud_instance_id = local.cloud_instance_id
#}

resource "ibm_pi_network" "power_network" {
  count                = 1
  pi_network_name      = var.network_name
  pi_cloud_instance_id = local.cloud_instance_id
  pi_network_type      = "vlan"
  pi_cidr              = "192.168.0.0/28"
  pi_gateway           = "192.168.0.1"
  pi_ipaddress_range {
    pi_starting_ip_address  = "192.168.0.2"
    pi_ending_ip_address    = "192.168.0.13"
  }
}
data "ibm_pi_network" "network" {
  depends_on           = [ibm_pi_network.power_network]
  pi_cloud_instance_id = local.cloud_instance_id
  pi_network_name = var.network_name
}


resource "ibm_pi_instance" "instance" {
  pi_cloud_instance_id = local.cloud_instance_id
  pi_memory            = var.memory
  pi_processors        = var.processors
  pi_instance_name     = var.instance_name
  pi_proc_type         = var.processor_type
  pi_image_id          = data.ibm_pi_image.power_image.id
  pi_key_pair_name     = data.ibm_pi_key.key.id
  pi_sys_type          = var.sys_type
  pi_storage_type      = var.storage_type
  pi_network {
    network_id = data.ibm_pi_network.network.id
  }
}
