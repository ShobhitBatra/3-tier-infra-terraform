# data "aws_ami" "custom" {
#   for_each    = toset(["web", "app", "db"])
#   most_recent = true
#   owners      = ["self"]

#   filter {
#     name   = "tag:Role"
#     values = [each.key]
#   }
# }
# Later will use to optimise it
# usage: ami = data.aws_ami.custom["web"].id

data "aws_ami" "ami_bastion" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
} 

data "aws_ami" "ami_web" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Role"
    values = ["web"]
  }
}


data "aws_ami" "ami_app" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Role"
    values = ["app"]
  }
}


data "aws_ami" "ami_db" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Role"
    values = ["db"]
  }
}
