# Creating Bastion host
resource "aws_instance" "ec2_bastion_a" {
  ami                         = data.aws_ami.ami_bastion.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_bastion.key_name
  vpc_security_group_ids      = [aws_security_group.sg_bastion.id]
  subnet_id                   = aws_subnet.subnet_public_infra_a.id
  associate_public_ip_address = true
  tags = {
    Name = "ec2-bastion-a"
  }
}