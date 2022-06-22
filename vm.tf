provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "OMDatacenter3"
}

data "vsphere_datastore_cluster" "datastore_cluster" {
  name          = "DataStoreCluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Cluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}


data "vsphere_network" "network" {
  name          = "VM-MGMT-10.60.x"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "vm_template" {
  name          = var.vsphere_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  count            = "${var.vsphere_vmcount}"
  name             = "${var.vsphere_vmname}${count.index+1}-${var.vsphere_ipstart}${count.index}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_cluster_id     = data.vsphere_datastore_cluster.datastore_cluster.id
  num_cpus         = data.vsphere_virtual_machine.vm_template.num_cpus
  memory           = data.vsphere_virtual_machine.vm_template.memory
  guest_id         = "centos7_64Guest"
  scsi_type        = data.vsphere_virtual_machine.vm_template.scsi_type
  firmware         = data.vsphere_virtual_machine.vm_template.firmware


  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            =  "disk${count.index}"
    size             = data.vsphere_virtual_machine.vm_template.disks.0.size
    eagerly_scrub    = false
    thin_provisioned = false
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.vm_template.id
    linked_clone  = "true"

    customize {

      linux_options {
        host_name = "acc-master${count.index+1}"
        domain    = ""
      }

      network_interface {
        ipv4_address = "${var.vsphere_ip}${var.vsphere_ipstart}${count.index}"
        ipv4_netmask = var.vsphere_ipv4_netmask
      }
      dns_server_list = [var.vsphere_dns_server1]
      ipv4_gateway = var.vsphere_ipv4_gateway
    }
 }

  provisioner "remote-exec" {

    inline =  [ 
      "sed -i s|PasswordAuthentication yes|PasswordAuthentication yes\nPermitRootLogin yes|' /etc/ssh/sshd_config",
      "systemctl restart sshd",
      "yum install -y nano",
    ]

    connection {
      type     = "ssh"
      user     = "root"
      password = ""
      host = "${var.vsphere_ip}${var.vsphere_ipstart}${count.index}"
    }
  }
}
