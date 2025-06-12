resource "aws_cloudwatch_event_rule" "schedule_rule" {
  name                = var.rule_name
  description         = var.description
  schedule_expression = var.schedule_expression

  tags = {
    Name = var.rule_name
  }
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge-${var.rule_name}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule_rule.arn
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule_rule.name
  target_id = var.target_id
  arn       = var.lambda_function_arn
}
