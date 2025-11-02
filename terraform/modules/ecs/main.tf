resource "aws_security_group" "task_sg" {
  name   = "${var.name}-task-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
    description     = "Allow ALB to create ECS tasks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "this" { name = var.cluster_name }

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.name}"
  retention_in_days = 14
}

data "aws_iam_policy_document" "exec_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "exec" {
  name               = "${var.name}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.exec_assume.json
}
resource "aws_iam_role_policy_attachment" "exec_attach" {
  role       = aws_iam_role.exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "task_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "task" {
  name               = "${var.name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
}

resource "aws_iam_policy" "secret_read" {
  count = length(var.secrets) > 0 ? 1 : 0
  name  = "${var.name}-secret-read"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      for s in var.secrets : {
        Effect   = "Allow",
        Action   = ["secretsmanager:GetSecretValue"],
        Resource = s.valueFrom
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "task_secret_attach" {
  count      = length(var.secrets) > 0 ? 1 : 0
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.secret_read[0].arn
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name}-td"
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.exec.arn
  task_role_arn            = aws_iam_role.task.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = var.name,
      image     = var.container_image,
      portMappings = [{ containerPort = var.container_port, hostPort = var.container_port, protocol = "tcp" }],
      essential = true,
      environment = [],
      secrets = var.secrets,
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name,
          awslogs-region        = var.region,
          awslogs-stream-prefix = var.name
        }
      },
      linuxParameters = {
        capabilities = { add = [], drop = ["ALL"] }
      },
      user = "1000",
      readonlyRootFilesystem = true,
      healthCheck = {
        command  = ["CMD-SHELL","wget -qO- http://127.0.0.1:${var.container_port}/health || exit 1"],
        interval = 30, timeout = 5, retries = 3, startPeriod = 10
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "${var.name}-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.task_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.name
    container_port   = var.container_port
  }

  depends_on = [var.alb_target_group_arn]
}