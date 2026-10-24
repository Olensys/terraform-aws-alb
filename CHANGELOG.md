# Changelog

## [1.0.2](https://github.com/Olensys/terraform-aws-alb/compare/v1.0.1...v1.0.2) (2026-10-24)


### Bug Fixes

* run integration on change and weekly instead of nightly ([7ae3a31](https://github.com/Olensys/terraform-aws-alb/commit/7ae3a31f884c13325825f75eacb2b2b70986e181))

## 1.0.1

### Fixes

- render declared provider constraints and skip .terraform in trivy scans
- declare required_version and providers in examples/minimal

## 1.0.0

Initial release: Application Load Balancer as a thin wrapper over `terraform-aws-modules/alb/aws` 10.5.1, with an HTTP-to-HTTPS redirect, an HTTPS listener (TLS 1.3 policy, fixed 404 default), invalid-header dropping, prod deletion protection and a managed security group.
