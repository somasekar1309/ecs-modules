# main.tf

module "ecs_task_definition" {
  source = "./modules/ecs-task-definition"

  # Add any necessary input variables for the ECS task definition module
  family                   = "my-task"
  container_definitions    = jsonencode([
    {
      name          = "my-container",
      image         = "nginx:latest",
      cpu           = 256,
      memory        = 512,
      essential     = true,
      portMappings  = [
        {
          containerPort = 80,
          hostPort      = 80
        }
      ]
    }
  ]),
  execution_role_arn       = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  network_mode             = "bridge",
  cpu                      = 256,
  memory                   = 512,
  requires_compatibilities = ["EC2"],
  task_role_arn            = "arn:aws:iam::123456789012:role/ecsTaskRole",
  volume_name              = "my-volume",
  volume_host_path         = "/var/log/myapp"
}

module "ecs_service" {
  source = "./modules/ecs-service"

  # Add any necessary input variables for the ECS service module
  name            = "my-service"
  cluster         = aws_ecs_cluster.ecs_cluster.arn
  task_definition = module.ecs_task_definition.ecs_task_definition_arn
  launch_type     = "EC2"
  desired_count   = 1

  network_configuration = {
    subnets          = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"],
    security_groups  = ["sg-0123456789abcdef0"],
    assign_public_ip = true
  }

  load_balancer = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/my-target-group/abc123abc123abc1",
    container_name   = "my-container",
    container_port   = 80
  }

  tags = {
    Environment = "Production"
  }
}

# Add any other resources or configurations here as needed
