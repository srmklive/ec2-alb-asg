resource "aws_security_group" "sg-test-web" {
  name = "sg_test_web"
  description = "Security Group for Web Server"
  vpc_id = var.vpc_id

  ingress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sg-test-web.id]
  subnet_id              = var.subnet_id

  tags = {
    Name = var.instance_tag
  }

  provisioner "file" {
    source      = "${path.module}/default-host.conf"
    destination = "/home/ubuntu/default-host.conf"
  }

  provisioner "file" {
    source      = "${path.module}/lamp_ubuntu.sh"
    destination = "/home/ubuntu/lamp_ubuntu.sh"
  }

  provisioner "file" {
    source      = "${path.module}/index.php"
    destination = "/home/ubuntu/index.php"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /server/http",
      "sudo cp /home/ubuntu/index.php /server/http/index.php",
      "sudo sed -i -e 's/\r$//' /home/ubuntu/lamp_ubuntu.sh",
      "sudo chmod +x /home/ubuntu/lamp_ubuntu.sh",
      "cd /home/ubuntu && sudo ./lamp_ubuntu.sh",
      "sudo cp /home/ubuntu/default-host.conf /etc/apache2/sites-available/000-default.conf",
      "sudo service apache2 restart",
      "sudo reboot"
    ]
  }

  root_block_device {
    delete_on_termination = "true"
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    password = ""
    host     = self.public_ip
    private_key = file("${path.module}/../../${var.key_name}.pem")
  }
}

resource "aws_ami_from_instance" "tf-ami" {
  name               = "tf-test-ami"
  source_instance_id = "${element(aws_instance.web_server.*.id, 0)}"
}
