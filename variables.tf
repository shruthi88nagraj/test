variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "UdacityProject1"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "WestUS"
}

variable "count" { 
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
