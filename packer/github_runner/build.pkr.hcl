build {
  name = "github-runner-ubuntu"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    script = "scripts/install-runner-exe.sh"
  }
}