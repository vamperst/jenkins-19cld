# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

variable "project" {
  default = "18cld"
}

data "aws_vpc" "vpc" {
  tags {
    Name = "${var.project}"
  }
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    Tier = "Public"
  }
}

data "aws_subnet" "public" {
  count = "${length(data.aws_subnet_ids.all.ids)}"
  id    = "${data.aws_subnet_ids.all.ids[count.index]}"
}

resource "random_shuffle" "random_subnet" {
  input        = ["${data.aws_subnet.public.*.id}"]
  result_count = 1
}


resource "aws_instance" "jenkins_master" {
  instance_type = "t2.micro"
  ami           = "${lookup(var.aws_amis, var.aws_region)}"

  count = 1

  subnet_id              = "${random_shuffle.random_subnet.result[0]}"
  vpc_security_group_ids = ["${aws_security_group.jenkins-master.id}"]
  key_name               = "${var.KEY_NAME}"
  iam_instance_profile = "${aws_iam_instance_profile.jenkins-master.id}"

  provisioner "file" {
    source      = "script-jenkins-master.sh"
    destination = "/tmp/script-jenkins-master.sh"
}

  provisioner "file" {
    source      = "/Users/rafaelbarbosa/.aws/config"
    destination = "/tmp/config"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script-jenkins-master.sh",
      "sudo /tmp/script-jenkins-master.sh",
    ]
  }

  

  connection {
    user        = "${var.INSTANCE_USERNAME}"
    private_key = "${file("${var.PATH_TO_KEY}")}"
  }

  tags {
    Name = "${format("jenkins-master-%03d", count.index + 1)}"
    Stage = "${var.stage}"
    Version = "${var.version}"
    Jenkins = "master"
  }
}