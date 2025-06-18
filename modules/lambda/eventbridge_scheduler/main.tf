resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  for_each           = var.lambda_schedules
  name               = each.value.target_id
  schedule_expression = each.value.schedule_expression
  description        = "Lambda Schedule for ${each.value.lambda_function_name}"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  for_each       = var.lambda_schedules
  rule           = aws_cloudwatch_event_rule.lambda_schedule[each.key].name
  target_id      = each.value.target_id
  arn            = each.value.lambda_function_arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  for_each = var.lambda_schedules
  statement_id  = "AllowExecutionFromEventBridge-${each.value.target_id}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule[each.key].arn
}