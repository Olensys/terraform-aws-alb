# Changelog

## 1.0.0

Initial release: Application Load Balancer as a thin wrapper over `terraform-aws-modules/alb/aws` 10.5.1, with an HTTP-to-HTTPS redirect, an HTTPS listener (TLS 1.3 policy, fixed 404 default), invalid-header dropping, prod deletion protection and a managed security group.
