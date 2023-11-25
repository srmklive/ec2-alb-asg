module "autoscaling" {
  source = "./modules/alb"

  ami           = var.ami
  security_group = aws_security_group.sg-tf-web.id
  instance_type = var.instance_type
  instance_tag  = var.instance_tag
  key_name      = var.key_name
  subnet_id     = aws_subnet.tf-web.id
  subnet_id1    = aws_subnet.tf-web1.id
}
