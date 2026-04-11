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

