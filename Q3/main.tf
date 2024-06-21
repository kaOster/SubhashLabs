resource "aws_vpc" "myproj3-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_subnet" "myproj3-subnet" {
  vpc_id            = aws_vpc.myproj3-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env}-subnet"
  }
}

resource "aws_internet_gateway" "myproj3-igw" {
  vpc_id = aws_vpc.myproj3-vpc.id

  tags = {
    Name = "${var.env}-igw"
  }

}

resource "aws_route_table" "myproj3-rtbl" {
  vpc_id = aws_vpc.myproj3-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myproj3-igw.id

  }
  tags = {
    Name = "${var.env}-rtbl"
  }

}

resource "aws_route_table_association" "myproj3-rtbla" {
  subnet_id      = aws_subnet.myproj3-subnet.id
  route_table_id = aws_route_table.myproj3-rtbl.id
}


resource "aws_security_group" "myproj3-sg" {
  name   = "myproj3-sg"
  vpc_id = aws_vpc.myproj3-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.myip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
  public_key = "${file(var.public_key_pair_path)}"

}

resource "aws_instance" "myproj3-ec2" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  user_data = file("install_tomcat.sh")

  subnet_id                   = aws_subnet.myproj3-subnet.id
  vpc_security_group_ids      = [aws_security_group.myproj3-sg.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key.key_name

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = "${file(var.private_key_pair_path)}"
  }

  provisioner "file" {  
    source      = "Check_Tomcat.sh"
    destination = "/home/ec2-user/Check_Tomcat.sh"
  }


  provisioner "file" {
    source      = "schedule.sh"
    destination = "/home/ec2-user/schedule.sh"
  }


  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/schedule.sh",
      "/home/ec2-user/schedule.sh",
    ]
  }
  tags = {
    Name = "${var.env}"
  }
}


