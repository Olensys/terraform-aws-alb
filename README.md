# terraform-aws-alb

Application Load Balancer with HTTPS-only listeners, HTTP redirect, TLS 1.3 policy and a managed security group

## Opinions

- HTTP:80 always redirects to HTTPS:443 (301). There is no plain-HTTP forwarding.
- HTTPS:443 listener default action is a fixed 404; attach listener rules to `https_listener_arn` to route traffic.
- `ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"` (TLS 1.3 with 1.2 fallback).
- `certificate_arn` is required whenever `create = true`: the module is HTTPS-only. It is enforced by an output precondition (cross-variable validation needs Terraform 1.9).
- `drop_invalid_header_fields = true`.
- `enable_deletion_protection = true` when `context.environment == "prod"`, otherwise false.
- A security group is created with ingress 80 and 443 from each of `ingress_cidrs` and egress to all.
- `internal` only toggles the scheme. Access logs are enabled only when `access_logs_bucket` is set (caller-owned bucket).

## Usage

```hcl
module "naming" {
  source  = "git::https://github.com/Olensys/terraform-null-naming.git?ref=v1.0.1"
  context = var.context
}

module "alb" {
  source  = "git::https://github.com/Olensys/terraform-aws-alb.git?ref=v1.0.1"
  name    = module.naming.name
  context = var.context

  vpc_id          = "vpc-0123456789abcdef0"
  subnet_ids      = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  certificate_arn = "arn:aws:acm:eu-west-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"

  tags = module.naming.tags
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0, < 7.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_this"></a> [this](#module\_this) | terraform-aws-modules/alb/aws | 10.5.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_context"></a> [context](#input\_context) | Deployment context used for naming, tagging and environment-dependent defaults. | <pre>object({<br/>    organization = string<br/>    environment  = string<br/>    application  = string<br/>    component    = optional(string)<br/>    owner        = string<br/>    cost_center  = string<br/>    extra_tags   = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Resource name. Lowercase letters, digits and hyphens. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs the load balancer is attached to. Use public subnets for an internet-facing ALB. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC the load balancer and its security group live in. | `string` | n/a | yes |
| <a name="input_access_logs_bucket"></a> [access\_logs\_bucket](#input\_access\_logs\_bucket) | Name of a caller-owned S3 bucket for access logs. Null disables access logging. | `string` | `null` | no |
| <a name="input_additional_certificate_arns"></a> [additional\_certificate\_arns](#input\_additional\_certificate\_arns) | Extra ACM certificate ARNs attached to the HTTPS listener for SNI. | `list(string)` | `[]` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ACM certificate ARN for the HTTPS:443 listener. Required whenever create is true; the module is HTTPS-only. | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether to create any resources. Set false to create nothing. | `bool` | `true` | no |
| <a name="input_idle_timeout_s"></a> [idle\_timeout\_s](#input\_idle\_timeout\_s) | Idle connection timeout in seconds. | `number` | `60` | no |
| <a name="input_ingress_cidrs"></a> [ingress\_cidrs](#input\_ingress\_cidrs) | IPv4 CIDR blocks allowed to reach ports 80 and 443. | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_internal"></a> [internal](#input\_internal) | Whether the load balancer is internal. Only toggles the scheme; listeners stay HTTPS-only. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags merged onto every taggable resource, applied last. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the load balancer. Null when create is false. |
| <a name="output_deletion_protection_enabled"></a> [deletion\_protection\_enabled](#output\_deletion\_protection\_enabled) | Whether deletion protection is requested (true in prod). Null when create is false. |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | DNS name of the load balancer. Null when create is false. |
| <a name="output_https_listener_arn"></a> [https\_listener\_arn](#output\_https\_listener\_arn) | ARN of the HTTPS:443 listener, the attachment point for listener rules. Null when create is false. |
| <a name="output_id"></a> [id](#output\_id) | ID of the load balancer. Null when create is false. |
| <a name="output_listener_config"></a> [listener\_config](#output\_listener\_config) | Listener configuration passed to the upstream module (no secrets). Null when create is false. |
| <a name="output_name"></a> [name](#output\_name) | Name of the load balancer. Null when create is false. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group managed by this module. Null when create is false. |
| <a name="output_ssl_policy"></a> [ssl\_policy](#output\_ssl\_policy) | TLS policy applied to the HTTPS listener. Null when create is false. |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to every taggable resource, with context.extra\_tags merged in. Null when create is false. |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | Route 53 hosted zone ID of the load balancer, for alias records. Null when create is false. |
<!-- END_TF_DOCS -->
