# Thin wrapper over terraform-aws-modules/alb/aws. The upstream call is named `this`.

locals {
  # Merge onto every taggable resource, with var.tags applied last.
  tags = merge(var.context.extra_tags, var.tags)

  ssl_policy          = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  deletion_protection = var.context.environment == "prod"

  use_existing_security_groups = length(var.security_group_ids) > 0

  # Opinion: HTTP always redirects to HTTPS; HTTPS answers 404 until the caller adds rules.
  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port                        = 443
      protocol                    = "HTTPS"
      certificate_arn             = var.certificate_arn
      additional_certificate_arns = var.additional_certificate_arns
      ssl_policy                  = local.ssl_policy
      fixed_response = {
        content_type = "text/plain"
        status_code  = "404"
        message_body = "not found"
      }
    }
  }

  ingress_rules = merge([
    for i, cidr in var.ingress_cidrs : {
      "http-${i}" = {
        description = "HTTP from ${cidr}"
        from_port   = "80"
        to_port     = "80"
        ip_protocol = "tcp"
        cidr_ipv4   = cidr
      }
      "https-${i}" = {
        description = "HTTPS from ${cidr}"
        from_port   = "443"
        to_port     = "443"
        ip_protocol = "tcp"
        cidr_ipv4   = cidr
      }
    }
  ]...)
}

module "this" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.5.1"

  create = var.create
  name   = var.name

  load_balancer_type = "application"
  internal           = var.internal
  vpc_id             = var.vpc_id
  subnets            = var.subnet_ids
  idle_timeout       = var.idle_timeout_s

  enable_deletion_protection = local.deletion_protection
  drop_invalid_header_fields = true

  create_security_group        = !local.use_existing_security_groups
  security_groups              = var.security_group_ids
  security_group_ingress_rules = local.use_existing_security_groups ? {} : local.ingress_rules
  security_group_egress_rules = {
    all = {
      description = "Allow all outbound traffic"
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  access_logs = var.access_logs_bucket == null ? null : {
    bucket  = var.access_logs_bucket
    enabled = true
  }

  listeners = local.listeners

  tags = local.tags
}
