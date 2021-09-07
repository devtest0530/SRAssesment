resource "aws_key_pair" "developerkey" {
  key_name   = "developerkey"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "web" {
  instance_type          = "t2.micro"
  ami                    = "ami-0c2b8ca1dad447f8a"
  vpc_security_group_ids = ["${aws_security_group.web_sg.name}"]
  key_name               = "${aws_key_pair.developerkey.key_name}"

  provisioner "remote-exec" {
    inline = [
      "echo 'build ssh connection'"
    ]

    connection {
      host = self.public_ip
      type = "ssh"
      user = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' --private-key ${var.pvt_key} provision.yml"
  }
  tags = {
    Name = Webserver
  }
}


resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow traffic for web apps on ec2"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ip" {
    description = "The EC2 ipv4 address"
    value = "${aws_instance.web.public_ip}"
}