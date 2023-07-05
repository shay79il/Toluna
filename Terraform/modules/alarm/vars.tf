variable "dimension" {
  type        = string
  description = "Cloudwatch metric dimension"
}

variable "alarm_name" {
  type        = string
  description = "Alarm Name"
}

variable "comparison_operator" {
  type        = string
  description = "Comparison Operator"
}

variable "evaluation_periods" {
  type        = number
  description = "The number of periods over which data is compared to the specified threshold"
}

variable "metric_name" {
  type        = string
  description = "The name for the alarm's associated metric"
}

variable "namespace" {
  type        = string
  description = "The namespace for the alarm's associated metric"
}

variable "period" {
  type        = number
  description = "The period in seconds over which the specified statistic is applied"
}

variable "statistic" {
  type        = string
  description = "The statistic to apply to the alarm's associated metric"
}

variable "threshold" {
  type        = number
  description = "The value against which the specified statistic is compared"
}

variable "alarm_description" {
  type        = string
  description = "The description for the alarm"
}

variable "alarm_actions" {
  type        = list(string)
  description = "The list of actions to execute when this alarm transitions into an ALARM state"
}