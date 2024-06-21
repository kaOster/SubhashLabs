resource "aws_vpc" "myproj2-vpc1" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env}-vpc1"
  }
}

resource "aws_vpc" "myproj2-vpc2" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env}-vpc2"
  }
}

resource "aws_subnet" "myproj2-subnet1" {
  vpc_id            = aws_vpc.myproj2-vpc1.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone1
  tags = {
    Name = "${var.env}-subnet1"
  }
}

resource "aws_subnet" "myproj2-subnet2" {
  vpc_id            = aws_vpc.myproj2-vpc2.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone2
  tags = {
    Name = "${var.env}-subnet2"
  }
}

resource "aws_internet_gateway" "myproj2-igw1" {
  vpc_id = aws_vpc.myproj2-vpc1.id

  tags = {
    Name = "${var.env}-igw1"
  }

}

resource "aws_internet_gateway" "myproj2-igw2" {
  vpc_id = aws_vpc.myproj2-vpc2.id

  tags = {
    Name = "${var.env}-igw2"
  }

}

resource "aws_route_table" "myproj2-rtbl1" {
  vpc_id = aws_vpc.myproj2-vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myproj2-igw1.id

  }
  tags = {
    Name = "${var.env}-rtbl1"
  }

}

resource "aws_route_table" "myproj2-rtbl2" {
  vpc_id = aws_vpc.myproj2-vpc2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myproj2-igw2.id

  }
  tags = {
    Name = "${var.env}-rtbl2"
  }

}

resource "aws_route_table_association" "myproj2-rtbla1" {
  subnet_id      = aws_subnet.myproj2-subnet1.id
  route_table_id = aws_route_table.myproj2-rtbl1.id
}

resource "aws_route_table_association" "myproj2-rtbla2" {
  subnet_id      = aws_subnet.myproj2-subnet2.id
  route_table_id = aws_route_table.myproj2-rtbl2.id
}

resource "aws_security_group" "myproj2-sg1" {
  name   = "myproj2-sg1"
  vpc_id = aws_vpc.myproj2-vpc1.id

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
    Name = "${var.env}-sg1"
  }
}

resource "aws_security_group" "myproj2-sg2" {
  name   = "myproj2-sg2"
  vpc_id = aws_vpc.myproj2-vpc2.id

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
    Name = "${var.env}-sg2"
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

resource "aws_instance" "myproj2-serverA" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  
  user_data = file("server_init.sh")

  subnet_id                   = aws_subnet.myproj2-subnet1.id
  vpc_security_group_ids      = [aws_security_group.myproj2-sg1.id]
  availability_zone           = var.avail_zone1
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key.key_name

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = "${file(var.private_key_pair_path)}"
  }

  provisioner "file" {  
    source      = "script_serverA.py"
    destination = "/home/ec2-user/script_serverA.py"
  }

  tags = {
    Name = "${var.env}-serverA"
  }
}


resource "aws_instance" "myproj2-serverB" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  
  user_data = file("server_init.sh")

  subnet_id                   = aws_subnet.myproj2-subnet2.id
  vpc_security_group_ids      = [aws_security_group.myproj2-sg2.id]
  availability_zone           = var.avail_zone2
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key.key_name

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = "${file(var.private_key_pair_path)}"
  }

  provisioner "file" {  
    source      = "script_serverB.py"
    destination = "/home/ec2-user/script_serverB.py"
  }


  tags = {
    Name = "${var.env}-serverB"
  }
}

resource "aws_sns_topic" "message_topic" {
  name = "message-topic"
}

resource "aws_sqs_queue" "message_queue" {
  name = "message-queue"
}

resource "aws_sns_topic_subscription" "sns_subscription" {
  topic_arn = aws_sns_topic.message_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.message_queue.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance-profile"
  role = aws_iam_role.sqs_role.name
}

resource "aws_iam_role" "sqs_role" {
  name = "sqs-role"

  assume_role_policy = jsonencode({
   
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "sqs.amazonaws.com"
        }
      }
    ]
  })
	 
}


resource "aws_iam_role_policy" "sqs_policy" {
  name = "sqs-policy"
  role = aws_iam_role.sqs_role.id

  policy = jsonencode({
   
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sqs:SendMessage",
        Resource = "${aws_sqs_queue.message_queue.arn}"
      },
      {
        Effect = "Allow",
        Action = "sns:Publish",
        Resource = "${aws_sns_topic.message_topic.arn}"
      }
    ]
  })
	 
}

resource "aws_sqs_queue_policy" "sqs_queue_policy" {
  queue_url = aws_sqs_queue.message_queue.id

  policy = jsonencode({
   
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "SQS:SendMessage",
        Resource = "${aws_sqs_queue.message_queue.arn}",
        Condition = {
          ArnEquals = {
            "aws:SourceArn": "${aws_sns_topic.message_topic.arn}"
          }
        }
      }
    ]
  })
	 
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role       = aws_iam_role.sqs_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

resource "aws_iam_role_policy_attachment" "sqs_policy_attach" {
  role       = aws_iam_role.sqs_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  role       = aws_iam_role.sqs_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


