resource "aws_internet_gateway" "jenkins_internet_gw" {
  vpc_id = aws_vpc.jenkins_vpc.id
    tags = {
    Name = "Jenkins Internet Gateway"
  }
}

resource "aws_eip" "eip1" {
}

resource "aws_eip" "eip2" {

}

resource "aws_nat_gateway" "jenkins_nat_gateway1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.pub_jenkins_subnet1.id

  depends_on = [aws_internet_gateway.jenkins_internet_gw]
  tags = {
    Name = "Jenkins NAT1"
  }
}

resource "aws_nat_gateway" "jenkins_nat_gateway2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.pub_jenkins_subnet2.id

  depends_on = [aws_internet_gateway.jenkins_internet_gw]
      tags = {
  Name = "Jenkins NAT2"
  }
}

resource "aws_vpc" "jenkins_vpc" {
  cidr_block = "192.1.0.0/20"
  enable_dns_hostnames = true
  tags = {
    Name = "Jenkins"
  }
}

resource "aws_subnet" "pub_jenkins_subnet1" {
  vpc_id     = aws_vpc.jenkins_vpc.id
  cidr_block = "192.1.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public 1 - Jenkins"
  }
}

resource "aws_subnet" "pub_jenkins_subnet2" {
  vpc_id     = aws_vpc.jenkins_vpc.id
  cidr_block = "192.1.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Public 2 - Jenkins"
  }
}

resource "aws_subnet" "private_jenkins_subnet1" {
  vpc_id     = aws_vpc.jenkins_vpc.id
  cidr_block = "192.1.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private 1 - Jenkins"
  }
}

resource "aws_subnet" "private_jenkins_subnet2" {
  vpc_id     = aws_vpc.jenkins_vpc.id
  cidr_block = "192.1.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private 2 - Jenkins"
  }  
}

resource "aws_route_table" "internet_route" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_internet_gw.id
  }
  tags = {
    Name = "Internet routing table - Jenkins"
  }  
}

resource "aws_route_table" "nat_route1" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.jenkins_nat_gateway1.id
  }
  tags = {
    Name = "Nat 1 routing table - Jenkins"
  }    
}

resource "aws_route_table" "nat_route2" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.jenkins_nat_gateway2.id
  }
  tags = {
    Name = "Nat 2 routing table - Jenkins"
  }  
}

resource "aws_route_table_association" "pub_jenkins_subnet1_route_assoc" {
  subnet_id      = aws_subnet.pub_jenkins_subnet1.id
  route_table_id = aws_route_table.internet_route.id
}

resource "aws_route_table_association" "pub_jenkins_subnet2_route_assoc" {
  subnet_id      = aws_subnet.pub_jenkins_subnet2.id
  route_table_id = aws_route_table.internet_route.id
}

resource "aws_route_table_association" "private_jenkins_subnet1_route_assoc" {
  subnet_id      = aws_subnet.private_jenkins_subnet1.id
  route_table_id = aws_route_table.nat_route1.id
}

resource "aws_route_table_association" "private_jenkins_subnet2_route_assoc" {
  subnet_id      = aws_subnet.private_jenkins_subnet2.id
  route_table_id = aws_route_table.nat_route2.id
}

resource "aws_acm_certificate" "jenkins-cert" {
  private_key=file("./self-sign-cert/key.pem")
  certificate_body = file("./self-sign-cert/certificate.pem")

  }

resource "aws_ssm_parameter" "jenkins_secret" {
  name        = "jenkins-pwd"
  description = "Jenkins Password"
  type        = "SecureString"
  value       = "password123#"
}