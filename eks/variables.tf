variable "cluster_name" {
}
variable "vpc_name" {
}
variable "vpc_cidr" {
}
variable "env_tag" {
}
variable "public_subnet_name" {
    type = list(string)
}
variable "private_subnet_name" {
    type = list(string)
}
variable "public_subnet" {
    type = list(string)
}
variable "private_subnet" {
    type = list(string)
}
variable "instance_type" {
    type = list(string)
}
variable "max_size" {
}
variable "min_size" {
}
variable "desired_size" {
}
variable "disk_size" {
}