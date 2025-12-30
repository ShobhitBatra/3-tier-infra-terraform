data "aws_ami_ids" "custom" {
  owners = ["self"]

  filter {
    name = "tag:Purpose"
    values = ["web","app","db"]
  }
}

