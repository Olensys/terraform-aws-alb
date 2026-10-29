mock_provider "aws" {
  # Valid ARN shape so the upstream listener resources accept the mocked load balancer.
  mock_resource "aws_lb" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:loadbalancer/app/example/50dc6c495c0c9188"
    }
  }
}

variables {
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }
  name            = "example"
  vpc_id          = "vpc-0123456789abcdef0"
  subnet_ids      = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  certificate_arn = "arn:aws:acm:eu-west-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
}

run "test_http_redirects_to_https" {
  command = plan

  # SMOKE: asserts the listener config handed to the upstream module (the module's own aws_lb_listener is not visible to terraform test); complete.tftest.hcl applies it for real.
  assert {
    condition     = output.listener_config.http.port == 80 && output.listener_config.http.protocol == "HTTP"
    error_message = "HTTP listener must be on port 80."
  }
  assert {
    condition     = output.listener_config.http.redirect.port == "443" && output.listener_config.http.redirect.protocol == "HTTPS" && output.listener_config.http.redirect.status_code == "HTTP_301"
    error_message = "HTTP listener must redirect to HTTPS:443 with a 301."
  }
}

run "test_tls13_policy" {
  command = plan

  # SMOKE: asserts the ssl_policy handed to the upstream module, not the deployed listener.
  assert {
    condition     = output.ssl_policy == "ELBSecurityPolicy-TLS13-1-2-2021-06"
    error_message = "ssl_policy must be the TLS 1.3 policy."
  }
  assert {
    condition     = output.listener_config.https.ssl_policy == "ELBSecurityPolicy-TLS13-1-2-2021-06" && output.listener_config.https.fixed_response.status_code == "404"
    error_message = "HTTPS listener must use the TLS 1.3 policy and a fixed 404 default action."
  }
}

run "test_deletion_protection_in_prod" {
  command = plan

  variables {
    context = {
      organization = "olensys"
      environment  = "prod"
      application  = "example"
      owner        = "platform"
      cost_center  = "eng"
    }
  }

  # SMOKE: asserts the value passed to the upstream module's enable_deletion_protection.
  assert {
    condition     = output.deletion_protection_enabled == true
    error_message = "Deletion protection must be on in prod."
  }
}

run "test_deletion_protection_off_in_dev" {
  command = plan

  variables {
    context = {
      organization = "olensys"
      environment  = "dev"
      application  = "example"
      owner        = "platform"
      cost_center  = "eng"
    }
  }

  # SMOKE: asserts the value passed to the upstream module's enable_deletion_protection.
  assert {
    condition     = output.deletion_protection_enabled == false
    error_message = "Deletion protection must be off outside prod."
  }
}

run "test_create_false_plans_nothing" {
  command = plan

  variables {
    create          = false
    certificate_arn = null
  }

  assert {
    condition = alltrue([
      output.id == null, output.name == null, output.arn == null, output.dns_name == null,
      output.zone_id == null, output.https_listener_arn == null, output.security_group_id == null,
      output.tags == null, output.listener_config == null, output.deletion_protection_enabled == null,
    ])
    error_message = "Every output must be null when create is false."
  }
}

run "test_name_length_validation" {
  command = plan

  variables {
    name = "abcdefghijklmnopqrstuvwxyz0123456" # 33 characters
  }

  expect_failures = [var.name]
}

run "test_certificate_required_when_creating" {
  command = plan

  variables {
    certificate_arn = null
  }

  expect_failures = [output.listener_config]
}

run "test_tags_contract" {
  command = plan

  variables {
    tags = { Owner = "x" }
    context = {
      organization = "olensys"
      environment  = "test"
      application  = "example"
      owner        = "platform"
      cost_center  = "eng"
      extra_tags   = { Owner = "y", Team = "z" }
    }
  }

  assert {
    condition     = output.tags.Owner == "x"
    error_message = "var.tags must win over context.extra_tags."
  }
  assert {
    condition     = output.tags.Team == "z"
    error_message = "context.extra_tags must be merged."
  }
}

run "test_existing_security_groups" {
  command = plan

  variables {
    security_group_ids = ["sg-0123456789abcdef0"]
  }

  assert {
    condition     = output.security_group_id == "sg-0123456789abcdef0"
    error_message = "security_group_id must be the supplied group when security_group_ids is set"
  }
}
