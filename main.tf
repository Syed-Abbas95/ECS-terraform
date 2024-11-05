resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = var.NAME
}

data "aws_vpc" "existing_vpc" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

data "aws_subnets" "available_subs" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing_vpc.id]
  }
}

resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg-tf"
  vpc_id = data.aws_vpc.existing_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = "ADIEC2S3FULLACCESS"
}

resource "aws_ecs_task_definition" "fargate_task" {
  family                   = "fargate-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  network_mode = "awsvpc"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::866934333672:role/ADIEC2S3FULLACCESS"
  container_definitions = jsonencode([{
    name      = "my-container"
    image     = "nginx" # Replace with your desired image
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
    }]
  }])
}

resource "aws_ecs_service" "fargate_service" {
  name            = "my-fargate-service"
  cluster         = aws_ecs_cluster.my_ecs_cluster.id
  task_definition = aws_ecs_task_definition.fargate_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = data.aws_subnets.available_subs.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}