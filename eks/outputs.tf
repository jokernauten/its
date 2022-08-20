output "vpc_id" {
  value = module.vpc.vpc_id
}

output "nat_eip" {
  value = aws_eip.nat.*.id
}

output "security_group" {
  value = aws_security_group.worker_group_mgmt.id
}

output "cluster_id" {
  value = module.eks.cluster_id
}
