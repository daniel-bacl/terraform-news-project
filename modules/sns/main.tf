resource "aws_sns_topic" "this" {
  name         = var.topic_name
  display_name = var.display_name != null ? var.display_name : var.topic_name
  tags         = var.tags
}

resource "aws_sns_topic_subscription" "subs" {
  for_each = { for idx, sub in var.subscriptions : idx => sub }

  topic_arn = aws_sns_topic.this.arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
  filter_policy = each.value.filter_policy
}