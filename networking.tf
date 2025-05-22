# VPC
resource "aws_vpc" "First_VPC" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "First_VPC"
    }
}

# Public Subnets 
resource "aws_subnet" "First_Public_Subnet" {
    vpc_id            = aws_vpc.First_VPC.id
    cidr_block        = "10.0.0.0/18"
    availability_zone = "us-east-2a"
    map_public_ip_on_launch = "true"

    tags = {
        Name = "First_Public_Subnet"
    }
}

resource "aws_subnet" "First_Public_Subnet_2" {
    vpc_id            = aws_vpc.First_VPC.id
    cidr_block        = "10.0.64.0/18"
    availability_zone = "us-east-2b"
    map_public_ip_on_launch = "true"
    tags = {
        Name = "First_Public_Subnet_2"
    }
}

# Private Subnets
resource "aws_subnet" "First_Private_Subnet_1" {
    vpc_id                  = aws_vpc.First_VPC.id
    cidr_block              = "10.0.128.0/18"
    availability_zone       = "us-east-2a"
    map_public_ip_on_launch = false
    tags = {
        Name = "First_Private_Subnet_1"
    }
}
resource "aws_subnet" "First_Private_Subnet_2" {
    vpc_id                  = aws_vpc.First_VPC.id
    cidr_block              = "10.0.192.0/18"
    availability_zone       = "us-east-2b"
    map_public_ip_on_launch = false
    tags = {
        Name = "First_Private_Subnet_2"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "First_IGW" {
    tags = {
        Name = "First_IGW"
    }
    vpc_id = aws_vpc.First_VPC.id
}

# Route Table
resource "aws_route_table" "First_RT" {
    tags = {
        Name = "First_RT"
    }
    vpc_id = aws_vpc.First_VPC.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.First_IGW.id
    }
}

# Route Table Associate
resource "aws_route_table_association" "First_RT_AS_1" {
    subnet_id      = aws_subnet.First_Public_Subnet.id
    route_table_id = aws_route_table.First_RT.id
}

resource "aws_route_table_association" "First_RT_AS_2" {
    subnet_id      = aws_subnet.First_Public_Subnet_2.id
    route_table_id = aws_route_table.First_RT.id
}

# Create Application Load Balancer (ALB)
resource "aws_lb" "first_alb" {
        name               = "Tw"
        internal           = false
        load_balancer_type = "application"
        subnets            = [aws_subnet.First_Public_Subnet.id, aws_subnet.First_Public_Subnet_2.id]

        tags = {
                Environment = "first_alb"
        }
}

resource "aws_lb_target_group" "first-alb-tg" {
        name     = "first-alb-tg"
        port     = 80
        protocol = "HTTP"
        vpc_id   = aws_vpc.First_VPC.id
}

resource "aws_lb_listener" "first-alb-listener" {
        load_balancer_arn = aws_lb.first_alb.arn
        port              = "80"
        protocol          = "HTTP"
        default_action {
                type             = "forward"
                target_group_arn = aws_lb_target_group.first-alb-tg.arn
        }
}

resource "aws_db_subnet_group" "two_tier_db_sub" {
        name       = "two_tier_db_sub"
        subnet_ids = [aws_subnet.First_Private_Subnet_1.id, aws_subnet.First_Private_Subnet_2.id]
}
resource "aws_eip" "nat_eip" {
}
resource "aws_nat_gateway" "first_nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.First_Public_Subnet.id

  tags = {
    Name = "First_NAT_Gateway"
  }
} 
resource "aws_route_table" "Private_RT" {
  vpc_id = aws_vpc.First_VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.first_nat_gw.id
  }

  tags = {
    Name = "Private_RT"
  }
} 
resource "aws_route_table_association" "Private_RT_Assoc_1" {
  subnet_id      = aws_subnet.First_Private_Subnet_1.id
  route_table_id = aws_route_table.Private_RT.id
}

resource "aws_route_table_association" "Private_RT_Assoc_2" {
  subnet_id      = aws_subnet.First_Private_Subnet_2.id
  route_table_id = aws_route_table.Private_RT.id
}
