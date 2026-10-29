# Changelog

## [1.1.0](https://github.com/Olensys/terraform-aws-alb/compare/v1.0.3...v1.1.0) (2026-10-29)


### Features

* add security_group_ids to attach existing security groups ([#7](https://github.com/Olensys/terraform-aws-alb/issues/7)) ([cc04905](https://github.com/Olensys/terraform-aws-alb/commit/cc049057e8e19509fb050e330e47292e49c2dc24))


### Bug Fixes

* **examples:** provision the listener certificate and validate through Cloudflare ([#4](https://github.com/Olensys/terraform-aws-alb/issues/4)) ([61d7e7d](https://github.com/Olensys/terraform-aws-alb/commit/61d7e7daa34cd6dd77e920ec960ac929452f7d96))

## [1.0.3](https://github.com/Olensys/terraform-aws-alb/compare/v1.0.2...v1.0.3) (2026-10-24)


### Bug Fixes

* **examples:** unique application slug so concurrent integration runs do not collide ([#2](https://github.com/Olensys/terraform-aws-alb/issues/2)) ([9573e4b](https://github.com/Olensys/terraform-aws-alb/commit/9573e4b30f479fc9be0d9f57dd48a7bd5d0d62b7))

## [1.0.2](https://github.com/Olensys/terraform-aws-alb/compare/v1.0.1...v1.0.2) (2026-10-24)


### Bug Fixes

* run integration on change and weekly instead of nightly ([7ae3a31](https://github.com/Olensys/terraform-aws-alb/commit/7ae3a31f884c13325825f75eacb2b2b70986e181))

## 1.0.1

### Fixes

- render declared provider constraints and skip .terraform in trivy scans
- declare required_version and providers in examples/minimal

## 1.0.0

Initial release: Application Load Balancer as a thin wrapper over `terraform-aws-modules/alb/aws` 10.5.1, with an HTTP-to-HTTPS redirect, an HTTPS listener (TLS 1.3 policy, fixed 404 default), invalid-header dropping, prod deletion protection and a managed security group.
