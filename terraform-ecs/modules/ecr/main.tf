resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration { scan_on_push = var.scan_on_push }

  encryption_configuration { encryption_type = "AES256" }
}

output "repository_url" { value = aws_ecr_repository.this.repository_url }