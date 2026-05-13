data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "database" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.db_instance_type
  subnet_id                   = aws_subnet.private[0].id
  vpc_security_group_ids      = [aws_security_group.database.id]
  associate_public_ip_address = false
  key_name                    = var.key_pair_name

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/templates/mysql-user-data.sh.tftpl", {
    db_name_b64          = base64encode(var.db_name)
    db_username_b64      = base64encode(var.db_username)
    db_password_b64      = base64encode(var.db_password)
    db_root_password_b64 = base64encode(var.db_root_password)
  })

  root_block_device {
    volume_size = var.db_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-mysql"
    Role = "database"
  })
}
