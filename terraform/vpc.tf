# ---------------------------
# VPC
# ---------------------------
resource "aws_vpc" "myonaiyoko_vpc"{
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true   # DNSホスト名を有効化
  tags = {
    Name = "terraform-myonaiyoko-vpc"
  }
}

# ---------------------------
# Subnet
# ---------------------------
resource "aws_subnet" "myonaiyoko_public_1a_sn" {
  vpc_id            = aws_vpc.myonaiyoko_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "terraform-myonaiyoko-public-1a-sn"
  }
}
resource "aws_subnet" "myonaiyoko_private-db_1a_sn" {
  vpc_id            = aws_vpc.myonaiyoko_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "terraform-myonaiyoko-private-db-1a-sn"
  }
}
resource "aws_subnet" "myonaiyoko_private-db_1c_sn" {
  vpc_id            = aws_vpc.myonaiyoko_vpc.id
  cidr_block        = "10.0.30.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "terraform-myonaiyoko-private-db-1c-sn"
  }
}

# ---------------------------
# Internet Gateway
# ---------------------------
resource "aws_internet_gateway" "myonaiyoko_igw" {
  vpc_id            = aws_vpc.myonaiyoko_vpc.id
  tags = {
    Name = "terraform-myonaiyoko-igw"
  }
}

# ---------------------------
# Route table
# ---------------------------
# Route table作成
resource "aws_route_table" "myonaiyoko_public_rt" {
  vpc_id            = aws_vpc.myonaiyoko_vpc.id
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.myonaiyoko_igw.id
  }
  tags = {
    Name = "terraform-myonaiyoko-public-rt"
  }
}

# SubnetとRoute tableの関連付け
resource "aws_route_table_association" "myonaiyoko_public_rt_associate" {
  subnet_id      = aws_subnet.myonaiyoko_public_1a_sn.id
  route_table_id = aws_route_table.myonaiyoko_public_rt.id
}
# ---------------------------
# Security Group
# ---------------------------
# 自分のパブリックIP取得
data "http" "ifconfig" {
  url = "http://ipv4.icanhazip.com/"
}

variable "allowed_cidr" {
  default = null
}

locals {
  myip          = chomp(data.http.ifconfig.body)
  allowed_cidr  = (var.allowed_cidr == null) ? "${local.myip}/32" : var.allowed_cidr
}

# Security Group作成
resource "aws_security_group" "myonaiyoko_ec2_sg" {
  name              = "terraform-myonaiyoko-ec2-sg"
  description       = "For EC2 Linux"
  vpc_id            = aws_vpc.myonaiyoko_vpc.id
  tags = {
    Name = "terraform-myonaiyoko-ec2-sg"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.allowed_cidr]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.allowed_cidr]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [local.allowed_cidr]
  }

  # アウトバウンドルール
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "myonaiyoko_rds_sg" {
  name              = "terraform-myonaiyoko-rds-sg"
  description       = "For RDS Linux"
  vpc_id            = aws_vpc.myonaiyoko_vpc.id
  tags = {
    Name = "terraform-myonaiyoko-rds-sg"
  }

  # インバウンドルール
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.10.0/24"]
  }

  # アウトバウンドルール
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------
# NAT Gateway
# ---------------------------
# EIP作成
resource "aws_eip" "myonaiyoko_eip" {
  vpc = true
}

# NAT Gateway作成
resource "aws_nat_gateway" "myonaiyoko_nat_gw" {
  allocation_id = aws_eip.myonaiyoko_eip.id
  subnet_id     = aws_subnet.myonaiyoko_public_1a_sn.id
}

# プライベートサブネットのRoute table作成とNAT Gatewayへのルート追加
resource "aws_route_table" "myonaiyoko_private_rt" {
  vpc_id            = aws_vpc.myonaiyoko_vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.myonaiyoko_nat_gw.id
  }

  tags = {
    Name = "terraform-myonaiyoko-private-rt"
  }
}

# プライベートサブネットとRoute tableの関連付け
resource "aws_route_table_association" "myonaiyoko_private_db_1a_rt_associate" {
  subnet_id      = aws_subnet.myonaiyoko_private-db_1a_sn.id
  route_table_id = aws_route_table.myonaiyoko_private_rt.id
}

resource "aws_route_table_association" "myonaiyoko_private_db_1c_rt_associate" {
  subnet_id      = aws_subnet.myonaiyoko_private-db_1c_sn.id
  route_table_id = aws_route_table.myonaiyoko_private_rt.id
}

