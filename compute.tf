# Creating web instances

# az-a
resource "aws_instance" "ec2_web_a" {
  ami                         = data.aws_ami.ami_web.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_private.key_name
  vpc_security_group_ids      = [aws_security_group.sg_web.id]
  subnet_id                   = aws_subnet.subnet_private_web_a.id
  associate_public_ip_address = false
  tags = {
    Name = "ec2-web-a"
  }
}

# az-b
resource "aws_instance" "ec2_web_b" {
  ami                         = data.aws_ami.ami_web.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_private.key_name
  vpc_security_group_ids      = [aws_security_group.sg_web.id]
  subnet_id                   = aws_subnet.subnet_private_web_b.id
  associate_public_ip_address = false
  tags = {
    Name = "ec2-web-b"
  }
}


# Creating app instances

# az-a
resource "aws_instance" "ec2_app_a" {
  ami                         = data.aws_ami.ami_app.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_private.key_name
  vpc_security_group_ids      = [aws_security_group.sg_app.id]
  subnet_id                   = aws_subnet.subnet_private_app_a.id
  associate_public_ip_address = false
  tags = {
    Name = "ec2-app-a"
  }
}

# az-b
resource "aws_instance" "ec2_app_b" {
  ami                         = data.aws_ami.ami_app.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_private.key_name
  vpc_security_group_ids      = [aws_security_group.sg_app.id]
  subnet_id                   = aws_subnet.subnet_private_app_b.id
  associate_public_ip_address = false
  tags = {
    Name = "ec2-app-b"
  }
}


# Creating db instances

# az-a
resource "aws_instance" "ec2_db_a" {
  ami                         = data.aws_ami.ami_db.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_private.key_name
  vpc_security_group_ids      = [aws_security_group.sg_db.id]
  subnet_id                   = aws_subnet.subnet_private_db_a.id
  associate_public_ip_address = false
  tags = {
    Name = "ec2-db-a"
  }
}

# az-b
resource "aws_instance" "ec2_db_b" {
  ami                         = data.aws_ami.ami_db.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_private.key_name
  vpc_security_group_ids      = [aws_security_group.sg_db.id]
  subnet_id                   = aws_subnet.subnet_private_db_b.id
  associate_public_ip_address = false
  tags = {
    Name = "ec2-db-b"
  }
}
