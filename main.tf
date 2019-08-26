data "template_file" "dd_message_elb" {
  template = "{{#is_alert}}$${lb_name} Unhealthy hosts rate is too high.{{/is_alert}}\n{{#is_alert_recovery}}$${lb_name} Unhealthy hosts rate is normal.{{/is_alert_recovery}}\n[Dashboard](https://app.datadoghq.com/screen/integration/80/aws-elb?tpl_var_scope=loadbalancername:$${lb_name})\n$${slack_channel}"

  vars = {
    slack_channel = var.dd_prod_slack_channel
    lb_name       = var.aws_lb_name
  }
}

resource "datadog_monitor" "aws_elb_unhealthy_hosts_rate" {
  count = var.aws_lb_type == "classic" ? 1 : 0

  message        = data.template_file.dd_message_elb.rendered
  name           = "Unhealthy hosts rate is high for ${var.aws_lb_name}"
  query          = "avg(last_1h):avg:aws.elb.un_healthy_host_count.maximum{loadbalancername:${var.aws_lb_name}} / avg:aws.elb.healthy_host_count.maximum{loadbalancername:${var.aws_lb_name}} >= ${var.unhealty_host_rate_threshold["critical"]}"
  type           = "query alert"
  notify_no_data = false
  tags           = [
    "service:devops",
    "loadbalancer"
  ]

  thresholds = {
    critical = var.unhealty_host_rate_threshold["critical"]
  }

  require_full_window = true
}
