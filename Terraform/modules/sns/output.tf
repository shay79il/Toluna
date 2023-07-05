output "sns_topics_arns" {
  value = values(aws_sns_topic.alarm)[*].arn

  description = "List of SNS Topics ARNs"
}