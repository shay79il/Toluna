resource "aws_sns_topic" "alarm" {
  for_each = toset(var.topics)
  name = each.value
}

resource "aws_sns_topic_subscription" "alarm" {
  for_each = aws_sns_topic.alarm

  topic_arn = each.value.arn
  protocol  = var.protocol
  endpoint  = var.endpoint
}