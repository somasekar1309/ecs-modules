# main.tf

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "my-task"
  container_definitions    = jsonencode([
    {
      name      = "my-container"
      image     = "nginx:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  execution_role_arn       = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
  network_mode             = "bridge"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["EC2"]
  task_role_arn            = "arn:aws:iam::123456789012:role/ecsTaskRole"
  
  volume {
    name      = "my-volume"
    host_path = "/var/log/myapp"
  }

  # CloudWatch Logs configuration
  dynamic "volume" {
    for_each = []

    content {
      name = "my-volume"

      dynamic "log_configuration" {
        for_each = [{
          log_driver = "awslogs"
          options = {
            "awslogs-group"         = "/ecs/my-container-logs"
            "awslogs-region"        = "us-west-2"
            "awslogs-stream-prefix" = "ecs"
          }
        }]

        content {
          log_driver = log_configuration.value.log_driver

          dynamic "options" {
            for_each = log_configuration.value.options

            content {
              name  = options.value.name
              value = options.value.value
            }
          }
        }
      }
    }
  }

  # Additional configurations
  tags = {
    Environment = "Production"
  }

  lifecycle {
    create_before_destroy = true
  }
}
