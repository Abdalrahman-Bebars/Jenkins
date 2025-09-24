resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = {
      Name = "main-igw"
    }
}

resource "aws_subnet" "subnet" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
      Name = "main-subnet"
    }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "a" {
    subnet_id      = aws_subnet.subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "ec2-sg" {
    name        = "ec2-sg"
    description = "Allow SSH and HTTP"
    vpc_id      = aws_vpc.main.id
    
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
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
}

resource "aws_key_pair" "deployer_key" {
  key_name   = "deployer-key"
  public_key = file("deployer-key.pub")
  tags = {
    Name = "deployer-key"
  }
}

resource "aws_instance" "jenkins-agent" {
    ami           = "ami-0360c520857e3138f" # Ubuntu Server 24.04 LTS (HVM), SSD Volume Type
    instance_type = "t3.micro"
    key_name      = "deployer-key" 
    subnet_id     = aws_subnet.subnet.id
    vpc_security_group_ids = [aws_security_group.ec2-sg.id]
    associate_public_ip_address = true
        
    tags = {
        Name = "Jenkins Agent"
    }
  
}

output "ec2_public_ip" {
    value = aws_instance.jenkins-agent.public_ip
}