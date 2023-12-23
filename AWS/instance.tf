# Original AWS provider configuration
# provider "aws" {
#   region = "us-east-1"
# }

# Resource using the original provider configuration
resource "aws_instance" "example_instance" {
  ami           = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
}

# Another AWS provider configuration with alias
provider "aws" {
  alias  = "another"
  region = "us-east-1"
}

# Resource using the provider with alias
resource "aws_instance" "another_instance" {
  provider      = aws.another
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
}
