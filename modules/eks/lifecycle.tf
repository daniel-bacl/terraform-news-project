resource "aws_ecr_lifecycle_policy" "spring_app" {
  repository = "spring-app"

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "최신 3개 태그만 보존"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v1.0."]
          countType     = "imageCountMoreThan"
          countNumber   = 3
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "1일 지난 untagged 삭제"
        selection = {
          tagStatus     = "untagged"
          countType     = "sinceImagePushed"
          countNumber   = 1
          countUnit     = "days"
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
