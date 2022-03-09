data "cloudflare_zones" "dns_zone" {
  filter {
    name = var.zone_name
  }
}

# Define the HTTP API in the API Gateway
resource "aws_apigatewayv2_api" "app" {
  name          = "app"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "app" {
  api_id = aws_apigatewayv2_api.app.id

  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
}

resource "aws_apigatewayv2_integration" "app" {
  api_id = aws_apigatewayv2_api.app.id

  integration_uri    = var.lambda_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "app" {
  api_id = aws_apigatewayv2_api.app.id

  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.app.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gateway/${aws_apigatewayv2_api.app.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id = "AllowExecutionFromAPIGateway"

  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.app.execution_arn}/*/*"
}

resource "aws_apigatewayv2_domain_name" "example" {
  domain_name = "${var.hostname}.${var.domain_name}"

  domain_name_configuration {
    certificate_arn = var.cert_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "example" {
  api_id      = aws_apigatewayv2_api.app.id
  domain_name = aws_apigatewayv2_domain_name.example.id
  stage       = aws_apigatewayv2_stage.app.id
}

resource "cloudflare_record" "hostname" {
  zone_id = data.cloudflare_zones.dns_zone.zones[0].id
  name    = var.hostname
  value   = aws_apigatewayv2_domain_name.example.domain_name_configuration[0].target_domain_name
  type    = "CNAME"
  ttl     = 1
  proxied = true
}
