# Run only by the nightly integration workflow, against real cloud credentials.
# The example provisions its own listener certificate, validated through Cloudflare.
# Inputs: TF_VAR_vpc_id, TF_VAR_subnet_ids, TF_VAR_zone_id (and optionally TF_VAR_zone_domain); CLOUDFLARE_API_TOKEN in the environment.
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
