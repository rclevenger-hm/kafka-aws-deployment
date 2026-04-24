resource "aws_s3_object" "node" {
  for_each     = local.nodes
  bucket       = aws_s3_bucket.runtime.id
  key          = "nodes/${each.key}.json"
  content_type = "application/json"
  content = jsonencode({
    schema_version = 1
    files          = local.runtime_files
    config = {
      node_id             = each.value.id
      node_name           = each.key
      role                = each.value.role
      zone                = each.value.zone
      region              = var.region
      fqdn                = "${each.key}.${var.dns_domain}"
      quorum              = local.quorum
      initial_controllers = local.initial_controllers
      cluster_id          = random_id.cluster.b64_url
      super_users         = local.super_users
      tls_secret_arn      = try(var.tls_secrets[each.key].arn, "MISSING")
      tls_secret_version  = try(var.tls_secrets[each.key].version_id, "MISSING")
      data_volume_id      = aws_ebs_volume.data[each.key].id
      kafka_version       = var.kafka_version
      kafka_sha512        = var.kafka_sha512
      retention_hours     = var.retention_hours
    }
  })
  lifecycle {
    precondition {
      condition     = toset(keys(var.tls_secrets)) == toset(keys(local.nodes))
      error_message = "tls_secrets must contain exactly one entry for every configured node name."
    }
    precondition {
      condition     = length(distinct([for s in values(var.tls_secrets) : s.arn])) == length(var.tls_secrets)
      error_message = "Each node requires its own secret ARN."
    }
  }
  depends_on = [aws_s3_bucket_versioning.runtime, aws_s3_bucket_server_side_encryption_configuration.runtime, aws_s3_bucket_public_access_block.runtime]
}
