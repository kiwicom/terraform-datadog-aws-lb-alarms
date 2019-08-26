variable "aws_lb_name" {
  type = string
}

variable "aws_lb_type" {
  type = string
}

variable "unhealty_host_rate_threshold" {
  type = map(string)

  default = {
    "critical" = "0.34"
  }
}

variable "dd_prod_slack_channel" {
  type = string
}
