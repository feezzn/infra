terraform {
  backend "s3" {
    bucket         = "felipe-tfstate-660830512266-v2"
    key            = "bootstrap/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-v2"
    encrypt        = true
  }
}

# Não precisa provider aqui, porque isso é só pra inicializar backend.