variable "name_prefix" {
  description = "Resource prefix; keep stable after deployment."
  type        = string
  default     = "kafka"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,14}[a-z0-9]$", var.name_prefix))
    error_message = "Use 3-16 lowercase letters, digits or hyphens."
  }
}


variable "client_cidrs" {
  description = "Explicit IPv4 client network allowlist; closed by default."
  type        = set(string)
  default     = []
  validation {
    condition     = alltrue([for c in var.client_cidrs : can(cidrnetmask(c)) && try(tonumber(split("/", c)[1]) >= 8, false) && can(regex("^(10\\.|192\\.168\\.|172\\.(1[6-9]|2[0-9]|3[01])\\.)", c)) && try(tonumber(split("/", c)[1]) >= (startswith(c, "10.") ? 8 : startswith(c, "172.") ? 12 : 16), false)])
    error_message = "Clients must use narrowly scoped RFC1918 IPv4 CIDRs."
  }
}


variable "metrics_cidrs" {
  description = "Private collector networks allowed to scrape port 9404."
  type        = set(string)
  default     = []
  validation {
    condition     = alltrue([for c in var.metrics_cidrs : can(cidrnetmask(c)) && try(tonumber(split("/", c)[1]) >= 16, false) && can(regex("^(10\\.|192\\.168\\.|172\\.(1[6-9]|2[0-9]|3[01])\\.)", c))])
    error_message = "Metrics require private IPv4 CIDRs of /16 or narrower."
  }
}


variable "broker_count" {
  description = "Broker count; adding brokers does not reassign partitions."
  type        = number
  default     = 3
  validation {
    condition     = var.broker_count >= 3 && var.broker_count <= 18 && floor(var.broker_count) == var.broker_count
    error_message = "Use an integer broker count from 3 to 18."
  }
}


variable "dns_domain" {
  description = "Private DNS suffix without trailing dot; dedicated zone."
  type        = string
  default     = "kafka.internal"
  validation {
    condition     = can(regex("^[a-z][a-z0-9.-]*[a-z0-9]$", var.dns_domain)) && strcontains(var.dns_domain, ".")
    error_message = "Use a lowercase DNS domain with no trailing dot."
  }
}


variable "admin_principals" {
  description = "Kafka certificate principals allowed to administer the cluster."
  type        = set(string)
  default     = ["User:CN=kafka-admin"]
  validation {
    condition     = length(var.admin_principals) > 0 && alltrue([for p in var.admin_principals : can(regex("^User:CN=[a-zA-Z0-9._-]+$", p))])
    error_message = "Use explicit simple certificate CN principals."
  }
}


variable "kafka_version" {
  description = "Pinned Kafka 4.1 release used by provisioning."
  type        = string
  default     = "4.1.2"
  validation {
    condition     = can(regex("^4\\.1\\.[0-9]+$", var.kafka_version))
    error_message = "This implementation supports the Kafka 4.1 release line."
  }
}


variable "kafka_sha512" {
  description = "Expected SHA-512 for the exact Kafka tarball."
  type        = string
  default     = "78ac6e488b1071122f9608dfdb363f6fe50e1dbbc492347002c0398dfbf77e0d8caa5bf794c5937379721004dfe92025937d238b0faf4eb715529417fd43b491"
  validation {
    condition     = can(regex("^[a-f0-9]{128}$", var.kafka_sha512))
    error_message = "Provide a lowercase SHA-512 digest."
  }
}


variable "retention_hours" {
  description = "Default retention period for newly created topics."
  type        = number
  default     = 168
  validation {
    condition     = var.retention_hours >= 1 && floor(var.retention_hours) == var.retention_hours
    error_message = "Retention must be positive whole hours."
  }
}

variable "region" {
  description = "Commercial AWS region containing all three availability zones."
  type        = string
  default     = "us-east-1"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.region))
    error_message = "Use a commercial AWS region such as us-east-1."
  }
}

variable "zones" {
  description = "Exactly three distinct standard availability zones in region."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  validation {
    condition     = length(var.zones) == 3 && length(toset(var.zones)) == 3 && alltrue([for z in var.zones : can(regex("^${var.region}[a-z]$", z))])
    error_message = "Select three distinct standard zones in region."
  }
}

variable "vpc_cidr" {
  description = "Dedicated RFC1918 IPv4 VPC, /16 through /20; six /19 through /23 subnets derived automatically."
  type        = string
  default     = "10.42.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr)) && can(regex("^(10\\.|192\\.168\\.|172\\.(1[6-9]|2[0-9]|3[01])\\.)", var.vpc_cidr)) && try(tonumber(split("/", var.vpc_cidr)[1]) >= 16 && tonumber(split("/", var.vpc_cidr)[1]) <= 20, false)
    error_message = "Use an RFC1918 IPv4 VPC between /16 and /20."
  }
}

variable "ami_id" {
  description = "Pinned Amazon-owned AL2023 standard x86_64 AMI in region; resolve and review before apply."
  type        = string
  validation {
    condition     = can(regex("^ami-[a-f0-9]{17}$", var.ami_id))
    error_message = "Provide a pinned AMI ID; do not use a moving latest image."
  }
}

variable "broker_instance_type" {
  description = "Nitro x86_64 EC2 type; benchmark network and EBS bandwidth."
  type        = string
  default     = "m6i.xlarge"
  validation {
    condition     = can(regex("^(m[6-7]i|m[6-7]a|r[6-7]i|r[6-7]a|c[6-7]i|c[6-7]a)\\.(large|xlarge|[0-9]+xlarge)$", var.broker_instance_type))
    error_message = "Use a supported x86_64 Nitro instance family, large or larger."
  }
}

variable "controller_instance_type" {
  description = "Nitro x86_64 EC2 type; benchmark network and EBS bandwidth."
  type        = string
  default     = "m6i.large"
  validation {
    condition     = can(regex("^(m[6-7]i|m[6-7]a|r[6-7]i|r[6-7]a|c[6-7]i|c[6-7]a)\\.(large|xlarge|[0-9]+xlarge)$", var.controller_instance_type))
    error_message = "Use a supported x86_64 Nitro instance family, large or larger."
  }
}

variable "broker_disk_gb" {
  description = "Encrypted gp3 data volume size in GiB."
  type        = number
  default     = 500
  validation {
    condition     = var.broker_disk_gb >= 20 && var.broker_disk_gb <= 16384 && floor(var.broker_disk_gb) == var.broker_disk_gb
    error_message = "Use a whole size from 20 to 16384 GiB."
  }
}

variable "controller_disk_gb" {
  description = "Encrypted gp3 data volume size in GiB."
  type        = number
  default     = 50
  validation {
    condition     = var.controller_disk_gb >= 20 && var.controller_disk_gb <= 16384 && floor(var.controller_disk_gb) == var.controller_disk_gb
    error_message = "Use a whole size from 20 to 16384 GiB."
  }
}

variable "broker_disk_iops" {
  description = "Provisioned gp3 IOPS; conservative portable range."
  type        = number
  default     = 3000
  validation {
    condition     = var.broker_disk_iops >= 3000 && var.broker_disk_iops <= 16000 && floor(var.broker_disk_iops) == var.broker_disk_iops && var.broker_disk_iops <= var.broker_disk_gb * 500
    error_message = "Use 3000-16000 whole IOPS, no more than 500 per GiB."
  }
}

variable "broker_disk_throughput" {
  description = "Provisioned gp3 throughput in MiB/s."
  type        = number
  default     = 125
  validation {
    condition     = var.broker_disk_throughput >= 125 && var.broker_disk_throughput <= 1000 && floor(var.broker_disk_throughput) == var.broker_disk_throughput && var.broker_disk_throughput <= var.broker_disk_iops / 4
    error_message = "Use 125-1000 whole MiB/s, no more than one quarter of IOPS."
  }
}

variable "tls_secrets" {
  description = "Node name to existing Secrets Manager ARN and immutable version ID. Payloads never enter Terraform."
  type        = map(object({ arn = string, version_id = string }))
  validation {
    condition     = alltrue([for s in values(var.tls_secrets) : can(regex("^arn:aws:secretsmanager:${var.region}:[0-9]{12}:secret:[A-Za-z0-9/_+=.@-]+$", s.arn)) && can(regex("^[A-Za-z0-9-]{32,64}$", s.version_id))])
    error_message = "Each node requires a Secrets Manager ARN in region and a 32-64 character immutable version ID."
  }
}

variable "secret_kms_key_arns" {
  description = "Optional customer-managed KMS keys used by TLS secrets; runtime decrypt is restricted to Secrets Manager."
  type        = set(string)
  default     = []
  validation {
    condition     = alltrue([for a in var.secret_kms_key_arns : can(regex("^arn:aws:kms:${var.region}:[0-9]{12}:key/[a-f0-9-]+$", a))])
    error_message = "Use KMS key ARNs in the selected region."
  }
}

variable "ebs_kms_key_arn" {
  description = "Optional customer-managed EBS encryption key ARN; null uses AWS managed EBS key."
  type        = string
  default     = null
  validation {
    condition     = var.ebs_kms_key_arn == null ? true : can(regex("^arn:aws:kms:${var.region}:[0-9]{12}:key/[a-f0-9-]+$", var.ebs_kms_key_arn))
    error_message = "Use a KMS key ARN in region or null."
  }
}

variable "deletion_protection" {
  description = "EC2 API termination protection; independent EBS prevent_destroy remains enforced."
  type        = bool
  default     = true
}

variable "enable_private_endpoints" {
  description = "Interface endpoints for SSM, session messages and Secrets Manager in every zone. NAT remains necessary for package downloads."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Capture VPC accepted and rejected traffic metadata to CloudWatch."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch flow-log retention."
  type        = number
  default     = 30
  validation {
    condition     = contains([7, 14, 30, 60, 90, 180, 365], var.log_retention_days)
    error_message = "Use one of 7,14,30,60,90,180,365 days."
  }
}

variable "alarm_topic_arns" {
  description = "Existing same-region SNS topics for alarms; empty creates visible alarms without notifications."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for a in var.alarm_topic_arns : can(regex("^arn:aws:sns:${var.region}:[0-9]{12}:[A-Za-z0-9_-]+$", a))])
    error_message = "Use same-region SNS topic ARNs."
  }
}

variable "tags" {
  description = "Additional ownership and billing tags."
  type        = map(string)
  default     = {}
}
