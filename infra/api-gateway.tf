resource "aws_api_gateway_rest_api" "stable_diffusion_api" {
  name        = "EventBannerAIAPI"
  description = "API for invoking Stable Diffusion model"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.stable_diffusion_api.id
  parent_id   = aws_api_gateway_rest_api.stable_diffusion_api.root_resource_id
  path_part   = "generate"
}

resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = aws_api_gateway_rest_api.stable_diffusion_api.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.stable_diffusion_api.id
  resource_id             = aws_api_gateway_resource.api_resource.id
  http_method             = aws_api_gateway_method.api_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.invoke_stable_diffusion.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.api_integration]
  rest_api_id = aws_api_gateway_rest_api.stable_diffusion_api.id
  stage_name  = "staging"
}
