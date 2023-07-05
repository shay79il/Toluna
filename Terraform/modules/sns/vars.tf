variable "topics" {
  type = list(string)
  description = "List of SNS topics"
}

variable "protocol" {
  type = string
  description = "Subscription protocol"
}


variable "endpoint" {
  type    = string
  description = "Subscription Email endpoint"
}