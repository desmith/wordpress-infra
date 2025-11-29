

# Route 53 record for subdomain pointing to CloudFront (alias record)
resource "aws_route53_record" "webserver_subdomain" {
  zone_id = var.hosted_zone_id
  name    = local.subdomain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.webserver.domain_name
    zone_id                = aws_cloudfront_distribution.webserver.hosted_zone_id
    evaluate_target_health = false
  }
}
