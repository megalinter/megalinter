resource "aws_instance" "instanceWithVpc" {
  ami           = "some-id"
  instance_type = "t2.micro"
  enable_monitoring = true 
  vpc_security_group_ids = ["sg-12345678901234567"]
  subnet_id              = "subnet-12345678901234567"

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name = "HelloWorld"
  }
}
