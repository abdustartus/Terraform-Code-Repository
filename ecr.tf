resource "aws_ecr_repository" "node_app" {
  name                 = "upgrad-node-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "upgrad-node-app-repo"
  }
}