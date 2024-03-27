# main.tf

resource "aws_ecs_service" "ecs_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.ecs_cluster.arn
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  launch_type     = "EC2"
  desired_count   = 1

  network_configuration {
    subnets          = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
    security_groups  = ["sg-0123456789abcdef0"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/my-target-group/abc123abc123abc1"
    container_name   = "my-container"
    container_port   = 80
  }

  # Additional configurations
  deployment_controller {
    type = "ECS"
  }

  tags = {
    Environment = "Production"
  }

  lifecycle {
    create_before_destroy = true
  }
}
