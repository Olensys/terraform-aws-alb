terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
  }
}

variable "vpc_id" {
  description = "VPC to place the load balancer in."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the load balancer."
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate for the HTTPS listener."
  type        = string
}

module "this" {
  source = "../../"

  name = "olensys-test-alb"
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "alb"
    owner        = "platform"
    cost_center  = "eng"
  }

  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
  certificate_arn = var.certificate_arn
}

output "dns_name" {
  description = "DNS name of the load balancer."
  value       = module.this.dns_name
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener."
  value       = module.this.https_listener_arn
}
