variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "UdacityProject2"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "WestUS"
}

variable "countVm" { 
  description = "Number of VM instances"  
  default = "2"
}

variable "VM_user_names" {
 description = "Create VM's with these user names"
 default = ["UdacityVm1", "UdacityVm2"]
}

variable "username" {
  description = "Username"
}

variable "password" {
  description = "user password"
}

variable "rg_tag" {
  description = "Adding resource group tag name as Project name"
  default = "UdacityProject2"
}
