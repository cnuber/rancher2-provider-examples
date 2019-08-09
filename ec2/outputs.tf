output "subnet_ids_private" {
  value = data.aws_subnet_ids.available_private.ids
}

output "subnet_ids_public" {
  value = data.aws_subnet_ids.available_public.ids
}
