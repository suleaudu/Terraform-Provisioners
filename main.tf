# Defining the provider configuration
provider "aws" {
    region = "us-east-1" # 
}
variable "cidr" {
    default = "10.0.0.0/16"
}
resource "aws_key_pair" "mykey" {
    key_name = "user-data1"
    public_key = file("~/.ssh/id_rsa.pub")
}
resource "aws_vpc" "myvpc"  {
  cidr_block = var.cidr
}

  
resource "aws_subnet" "sub1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone =  "us-east-1a"
  map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

    }
}
  resource "aws_route_table_association" "rt1a" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
  }
resource "aws_security_group" "websg" {
  name        = "web"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    # Description  "HTTP from VPC" 
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # Descriptin "SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web-sg"
  }
}
resource "aws_instance" "server" {
    ami = "ami-0f403e3180720dd7e"
    instance_type = "t2.micro"
    key_name = aws_key_pair.mykey.key_name
    vpc_security_group_ids = [aws_security_group.websg.id]
    subnet_id = aws_subnet.sub1.id

connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host = self.public_ip
  }

# File provisioner to copy a file from local to remote ec2 instance
provisioner "file" {
    source = "app.py"
    destination = "/home/ec2-user/app.py"
}
provisioner "remote-exec" {
    inline = [
        "echo 'Hello from remote instance'",
        "sudo yum update -y",
        "sudo yum install -y python3-pip",
        "cd /home/ec2-user",
        "sudo pip3 install flask",
        "sudo python3 app.py &",
    ]
        
    }
}
