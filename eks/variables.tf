variable "cluster_name" {
}
variable "vpc_name" {
}
variable "vpc_cidr" {
}
variable "env_tag" {
    type = string
}
variable "public_subnets" {
    type = list(string)
}
variable "private_subnets" {
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