source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_name}-${var.version}"
  instance_type = "t3.micro"
  region        = var.region

  vpc_id    = var.vpc_id

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}