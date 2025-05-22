# Create EC2 Security Group
resource "aws_security_group" "TwoTierSecurityGroup" {
    name        = "TwoTierSecurityGroup"
    description = "Allow traffic from VPC"
    vpc_id      = aws_vpc.First_VPC.id

    ingress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

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

    tags = {
        Name = "two_tier_ec2_sg"
    }
}

# Load Balancer Security Group
resource "aws_security_group" "TwoTierALBSecurityGroup" {
    name        = "TwoTierALBSecurityGroup"
    description = "Load balancer security group"
    vpc_id      = aws_vpc.First_VPC.id

    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "TwoTierALBSecurityGroup"
    }
}

# Database Security Group
resource "aws_security_group" "TwoTierDBSecurityGroup" {
    name        = "TwoTierDBSecurityGroup"
    description = "Allow traffic from EC2"
    vpc_id      = aws_vpc.First_VPC.id

    ingress {
        from_port       = 3306
        to_port         = 3306
        protocol        = "tcp"
        security_groups = [aws_security_group.TwoTierSecurityGroup.id]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "TwoTierDBSecurityGroup"
    }
}
