variable "vsphere_server" {
  default     = ""  
}

variable "vsphere_user" {
  default = ""
}

variable "vsphere_password" {
  default = ""
}

variable "vsphere_template" {
  default = "Tf-CentOS-7.9-Master"
}

variable "vsphere_vmname" {
  default = "jslee-master"
}

variable "vsphere_vmcount" {
  type    = number
  default = "1"
}

variable "vsphere_ip" {
  default = "10.60.200."
}

variable "vsphere_ipv4_gateway" {
  default = "10.60.0.1"
}

variable "vsphere_dns_server1" {
  default = "10.20.200.41"
}

variable "vsphere_ipv4_netmask" {
  type    = number
  default = "16"
}

variable "vsphere_ipstart" {
  default = "24"
}




