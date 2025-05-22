data "aws_ami" "amazon_linux" {
    most_recent = true
    owners      = ["amazon"]

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_instance" "linux_instance_1" {
    ami                         = data.aws_ami.amazon_linux.id
    instance_type               = "t2.micro"
    subnet_id                   = aws_subnet.First_Private_Subnet_1.id
    vpc_security_group_ids      = [aws_security_group.TwoTierSecurityGroup.id]

    user_data = <<-EOF
                            #!/bin/bash
                            yum update -y
                            yum install -y httpd
                            systemctl start httpd
                            systemctl enable httpd
                            echo "Hello from Web_Server_1" > /var/www/html/index.html
                            EOF

    tags = {
        Name = "Linux_Instance_1"
    }
}

resource "aws_instance" "linux_instance_2" {
    ami                         = data.aws_ami.amazon_linux.id
    instance_type               = "t2.micro"
    subnet_id                   = aws_subnet.First_Private_Subnet_2.id
    vpc_security_group_ids      = [aws_security_group.TwoTierSecurityGroup.id]

    user_data = <<-EOF
                            #!/bin/bash
                            yum update -y
                            yum install -y httpd
                            systemctl start httpd
                            systemctl enable httpd
                            echo "Hello from Web_Server_2" > /var/www/html/index.html
                            EOF

    tags = {
        Name = "Linux_Instance_2"
    }
}

resource "aws_lb_target_group_attachment" "linux_instance_1_attachment" {
    target_group_arn = aws_lb_target_group.first-alb-tg.arn
    target_id        = aws_instance.linux_instance_1.id
    port             = 80
}

resource "aws_lb_target_group_attachment" "linux_instance_2_attachment" {
    target_group_arn = aws_lb_target_group.first-alb-tg.arn
    target_id        = aws_instance.linux_instance_2.id
    port             = 80
}
