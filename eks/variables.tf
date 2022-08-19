variable "cluster_name" {
}
variable "vpc_name" {
}
variable "vpc_cidr" {
}
variable "env_tag" {
    type = string
}
variable "private_subnet_name" {
}
variable "public_subnet_name" {
}
variable "public_subnet" {
    type = list(string)
}
variable "private_subnet" {
    type = list(string)
}
variable "instance_type" {
}
variable "max_size" {
}
variable "min_size" {
}
variable "desired_size" {
}
variable "disk_size" {
}