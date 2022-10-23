resource "aws_ecr_repository" "repository" {
  name                 = "frontend-${terraform.workspace}"
  image_tag_mutability = "MUTABLE"
}