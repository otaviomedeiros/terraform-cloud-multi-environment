data "aws_iam_policy_document" "task_definition" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_definition" {
  name               = "task-definition-${var.env_name}"
  assume_role_policy = data.aws_iam_policy_document.task_definition.json
}

resource "aws_iam_role_policy_attachment" "app_tast_definition_policy" {
  role       = aws_iam_role.task_definition.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}