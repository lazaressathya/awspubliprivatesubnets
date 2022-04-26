variable "vpc_cidr" {
    default = "10.0.0.0/16" 
}
variable "subnet1" {
    default = "10.0.1.0/24"
  
}
variable "subnet2" {
    default = "10.0.2.0/24"
  
}
variable "az1" {
    default = "ap-south-1a"
  
}
variable "az2" {
    default = "ap-south-1b"
  
}
variable "publicroute" {
    default = "0.0.0.0/0"
  
}