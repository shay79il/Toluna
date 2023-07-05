locals {
  image_arn = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.image_name}:latest"
}

resource "aws_ecs_cluster" "this" {
  name = "toluna-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name        = "ECS Cluster"
    Description = "ECS for ${var.env} environment"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "toluna-task"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions = jsonencode([
    {
      name      = var.image_name
      image     = local.image_arn
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
        }
      ]
    }
  ])

  tags = {
    Name        = "ECS task definition"
    Description = "Task definition for the container"
  }
}

# Create ECS service
resource "aws_ecs_service" "this" {
  name            = "ecs-servic"
  cluster         = aws_ecs_cluster.this.name
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type


  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = var.security_group_ids
  }

  load_balancer {
    target_group_arn = var.tg_ecs_fargate_arn
    container_name   = var.image_name
    container_port   = var.container_port
  }

  tags = {
    Name        = "ECS Service"
    Description = "ECS service for managing the task definition"
  }
}

