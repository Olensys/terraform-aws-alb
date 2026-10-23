variable "name" {
  description = "Resource name. Lowercase letters, digits and hyphens."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{1,32}$", var.name))
    error_message = "name must match ^[a-z0-9-]{1,32}$."
  }
}

variable "context" {
  description = "Deployment context used for naming, tagging and environment-dependent defaults."
  type = object({
    organization = string
    environment  = string
    application  = string
    component    = optional(string)
    owner        = string
    cost_center  = string
    extra_tags   = optional(map(string), {})
  })
  validation {
    condition     = contains(["dev", "staging", "prod", "test", "shared"], var.context.environment)
    error_message = "context.environment must be one of dev, staging, prod, test, shared."
  }
}

variable "create" {
  description = "Whether to create any resources. Set false to create nothing."
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID of the VPC the load balancer and its security group live in."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs the load balancer is attached to. Use public subnets for an internet-facing ALB."
  type        = list(string)
}

variable "internal" {
  description = "Whether the load balancer is internal. Only toggles the scheme; listeners stay HTTPS-only."
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS:443 listener. Required whenever create is true; the module is HTTPS-only."
  type        = string
  default     = null
  validation {
    condition     = var.certificate_arn == null || can(regex("^arn:[^:]+:acm:", var.certificate_arn))
    error_message = "certificate_arn must be an ACM certificate ARN."
  }
}

variable "additional_certificate_arns" {
  description = "Extra ACM certificate ARNs attached to the HTTPS listener for SNI."
  type        = list(string)
  default     = []
}

variable "ingress_cidrs" {
  description = "IPv4 CIDR blocks allowed to reach ports 80 and 443."
  type        = list(string)
  default     = ["0.0.0.0/0"]
  validation {
    condition     = alltrue([for c in var.ingress_cidrs : can(cidrhost(c, 0))])
    error_message = "ingress_cidrs must contain valid IPv4 CIDR blocks."
  }
}

variable "access_logs_bucket" {
  description = "Name of a caller-owned S3 bucket for access logs. Null disables access logging."
  type        = string
  default     = null
}

variable "idle_timeout_s" {
  description = "Idle connection timeout in seconds."
  type        = number
  default     = 60
  validation {
    condition     = var.idle_timeout_s >= 1 && var.idle_timeout_s <= 4000
    error_message = "idle_timeout_s must be between 1 and 4000."
  }
}

variable "tags" {
  description = "Tags merged onto every taggable resource, applied last."
  type        = map(string)
  default     = {}
}
