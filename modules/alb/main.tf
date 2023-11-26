resource "aws_launch_configuration" "web" {
  name_prefix = "web-"

  image_id = var.ami
  instance_type = var.instance_type
  key_name = var.key_name

  security_groups = [ "${var.security_group}" ]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

# target group
resource "aws_lb_target_group" "target-group" {
  name        = "web-alb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "${var.vpc_id}"

  health_check {
    enabled             = true
    interval            = 10
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb" "web-alb" {
  name = "web-elb"
  security_groups = [
    "${var.security_group}"
  ]
  subnets = [
    "${var.subnet_id}",
    "${var.subnet_id1}"
  ]

  load_balancer_type = "application"
  enable_cross_zone_load_balancing   = true
}

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.web-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

resource "aws_autoscaling_group" "web" {
  name = "web-asg"

  min_size             = var.min_size
  desired_capacity     = var.min_size
  max_size             = var.max_size
  
  health_check_type    = "ELB"
  target_group_arns = [
    "${aws_lb_target_group.target-group.arn}"
  ]

  launch_configuration = "${aws_launch_configuration.web.name}"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier  = [
    "${var.subnet_id}",
    "${var.subnet_id1}"
  ]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_policy" "web_policy_up" {
  name = "web_policy_up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
  alarm_name = "web_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "${var.max_threshold}"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.web.name}"
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [ "${aws_autoscaling_policy.web_policy_up.arn}" ]
}

resource "aws_autoscaling_policy" "web_policy_down" {
  name = "web_policy_down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
  alarm_name = "web_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "${var.min_threshold}"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.web.name}"
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [ "${aws_autoscaling_policy.web_policy_down.arn}" ]
}

resource "aws_autoscaling_policy" "web_policy_predictive" {
 name                   = "policy_predictive"
 policy_type            = "PredictiveScaling"
 autoscaling_group_name = aws_autoscaling_group.web.name
 predictive_scaling_config {
   metric_specification {
     target_value = "${var.min_threshold}"
     predefined_scaling_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
      resource_label         = "AverageCPUUtilization"
     }
     predefined_load_metric_specification {
      predefined_metric_type = "ASGTotalCPUUtilization"
      resource_label         = "TotalCPUUtilization"
     }
   }
   mode                          = "ForecastAndScale"
   scheduling_buffer_time        = var.max_buffer_time
   max_capacity_breach_behavior  = "IncreaseMaxCapacity"
   max_capacity_buffer           = var.max_capacity_buffer
 }
}
