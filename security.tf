# Creating key_pair for bastion host
resource "aws_key_pair" "key_bastion" {
  key_name   = "bastion"
  public_key = file("~/.ssh/bastion.pub")
}

# Creating key_pair for private instances 
resource "aws_key_pair" "key_private" {
  key_name   = "private"
  public_key = file("~/.ssh/private.pub")
}


# Creating sg for alb
resource "aws_security_group" "sg_alb" {
  name = "sg-alb"
  description = "security group for our alb"
  vpc_id = aws_vpc.vpc_main.id
  tags = {
    Name="sg-alb"
  }
}

resource "aws_security_group_rule" "http" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"  
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_alb.id
}

resource "aws_security_group_rule" "allow_all_outbound_alb" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_alb.id
}


# Creating sg for web tier instances
resource "aws_security_group" "sg_web" {
  name = "sg-web"
  description = "security group for our instances in web tier"
  vpc_id = aws_vpc.vpc_main.id
  tags = {
    Name="sg-web"
  }
}

resource "aws_security_group_rule" "allow_alb_to_web" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.sg_web.id
  source_security_group_id = aws_security_group.sg_alb.id
}

resource "aws_security_group_rule" "ssh_web" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.sg_web.id
  source_security_group_id = aws_security_group.sg_bastion.id
}

resource "aws_security_group_rule" "allow_all_outbound_web" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_web.id
}

# Creating sg for app tier instances
resource "aws_security_group" "sg_app" {
  name = "sg-app"
  description = "security group for our instances in app tier"
  vpc_id = aws_vpc.vpc_main.id
  tags = {
    Name="sg-app"
  }
}

resource "aws_security_group_rule" "allow_web_to_app" {
  type = "ingress"
  from_port = 5000
  to_port = 5000
  protocol = "tcp"
  security_group_id = aws_security_group.sg_app.id
  source_security_group_id = aws_security_group.sg_web.id
}

resource "aws_security_group_rule" "ssh_app" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.sg_app.id
  source_security_group_id = aws_security_group.sg_bastion.id
}

resource "aws_security_group_rule" "allow_all_outbound_app" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_app.id
}


# Creating sg for db tier instances
resource "aws_security_group" "sg_db" {
  name = "sg-db"
  description = "security group for our instances in db tier"
  vpc_id = aws_vpc.vpc_main.id
}

resource "aws_security_group_rule" "allow_app_to_db" {
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  security_group_id = aws_security_group.sg_db.id
  source_security_group_id = aws_security_group.sg_app.id
}

resource "aws_security_group_rule" "ssh_db" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.sg_db.id
  source_security_group_id = aws_security_group.sg_bastion.id
}

resource "aws_security_group_rule" "allow_all_outbound_db" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_db.id
}


# Creating sg for bastion host
resource "aws_security_group" "sg_bastion" {
  name = "sg-bastion"
  description = "security group for our bastion host"
  vpc_id = aws_vpc.vpc_main.id
}

resource "aws_security_group_rule" "ssh_bastion" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_bastion.id
}

resource "aws_security_group_rule" "allow_all_outbound_bastion" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_bastion.id
}
