

# Route 53 record for subdomain pointing to CloudFront or ALB (alias record)
resource "aws_route53_record" "webserver_subdomain" {
  zone_id = var.hosted_zone_id
  name    = var.hostname
  type    = "A"

  alias {
    name                   = var.cloudfront_distro ? aws_cloudfront_distribution.webserver[0].domain_name : data.aws_lb.existing_lb.dns_name
    zone_id                = var.cloudfront_distro ? aws_cloudfront_distribution.webserver[0].hosted_zone_id : data.aws_lb.existing_lb.zone_id
    evaluate_target_health = false
  }
}
