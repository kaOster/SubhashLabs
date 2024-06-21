resource "aws_vpc" "myproj1-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_subnet" "myproj1-subnet" {
  vpc_id            = aws_vpc.myproj1-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env}-subnet"
  }
}

resource "aws_internet_gateway" "myproj1-igw" {
  vpc_id = aws_vpc.myproj1-vpc.id

  tags = {
    Name = "${var.env}-igw"
  }

}

resource "aws_route_table" "myproj1-rtbl" {
  vpc_id = aws_vpc.myproj1-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myproj1-igw.id

  }
  tags = {
    Name = "${var.env}-rtbl"
  }

}

resource "aws_route_table_association" "myproj1-rtbla" {
  subnet_id      = aws_subnet.myproj1-subnet.id
  route_table_id = aws_route_table.myproj1-rtbl.id
}


resource "aws_security_group" "myproj1-sg" {
  name   = "myproj1-sg"
  vpc_id = aws_vpc.myproj1-vpc.id

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

resource "aws_instance" "myproj1-ec2" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  user_data = file("webserver.sh")

  subnet_id                   = aws_subnet.myproj1-subnet.id
  vpc_security_group_ids      = [aws_security_group.myproj1-sg.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key.key_name

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = "${file(var.private_key_pair_path)}"
  }

  tags = {
    Name = "${var.env}"
  }
}


