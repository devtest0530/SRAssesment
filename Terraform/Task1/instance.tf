resource "aws_key_pair" "developerkey" {
  key_name   = "developerkey"
  public_key = file("${path.module}/new.pub")
}

resource "aws_instance" "web" {
  instance_type          = "t2.micro"
  ami                    = "ami-0077db84180877c47"
  vpc_security_group_ids = ["${aws_security_group.web_sg.id}"]
  key_name               = "${aws_key_pair.developerkey.key_name}"
}


resource "aws_security_group" "web_sg" {
  name        = "nginx_sg"
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