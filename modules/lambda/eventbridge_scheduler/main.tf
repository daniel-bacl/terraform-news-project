resource "aws_cloudwatch_event_rule" "schedule" {
  for_each            = var.lambda_schedules
  name                = each.key
  description         = lookup(each.value, "description", "")
  schedule_expression = each.value.schedule_expression
  tags = { Name = each.key }
}

resource "aws_lambda_permission" "allow_eventbridge" {
  for_each      = var.lambda_schedules
  statement_id  = "AllowExecutionFromEventBridge-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule[each.key].arn
}

resource "aws_cloudwatch_event_target" "lambda" {
  for_each = var.lambda_schedules
  rule      = aws_cloudwatch_event_rule.schedule[each.key].name
  target_id = each.value.target_id
  arn       = each.value.lambda_function_arn
}
