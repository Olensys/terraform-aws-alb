# Run only by the nightly integration workflow, against real cloud credentials.
# Requires TF_VAR_vpc_id, TF_VAR_subnet_ids and TF_VAR_certificate_arn for a real VPC and ACM certificate.
run "apply_minimal" {
  command = apply

  module {
    source = "./examples/minimal"
  }

  assert {
    condition     = output.dns_name != null && output.https_listener_arn != null
    error_message = "The load balancer and its HTTPS listener must exist after apply."
  }
}
