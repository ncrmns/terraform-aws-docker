variable "username" {
		type = string
}
variable "password" {
		type = string
}
variable "privatekey" {
		type = string
}
variable "keyname" {
		type = string
}
variable "region" {
    default = "us-east-1"
}
variable "server_names" {
    type = list
}
provider "aws" {
    profile    = "ncrmns"
  region     = var.region 
}
resource "aws_instance" "ncrmns-terraform" {
  ami           = "ami-026c8acd92718196b"
  instance_type = "t2.micro"
    key_name = "${var.keyname}"
    count = 1
    tags = {
        Name = var.server_names[count.index]
    }
		provisioner "file" {
				source = "createuser.sh"
				destination = "/tmp/createuser.sh"
				connection {
						type = "ssh"
						host = self.public_ip
						user = "ubuntu"
						private_key = file("${var.privatekey}")
				}
		}
		provisioner "remote-exec" {
				inline = [
						"bash /tmp/createuser.sh ${var.username} ${var.password}"
				]
				connection {
						type = "ssh"
						host = self.public_ip
						user = "ubuntu"
						private_key = file("${var.privatekey}")
				}
		}
    provisioner "file" {
        source = "dockerInstall.sh"
        destination = "/tmp/dockerInstall.sh"
        connection {
            type = "ssh"
            host = self.public_ip
            user = "ubuntu"
            private_key = file("${var.privatekey}")
        }
    }
    provisioner "remote-exec" {
        inline = [
            "bash /tmp/dockerInstall.sh"
        ]
        connection {
            type = "ssh"
            host = self.public_ip
            user = "ubuntu"
            private_key = file("${var.privatekey}")
        }
    }
    provisioner "remote-exec" {
        inline = [
            "sudo docker pull ncrmns/helloworld11",
            "sudo docker run -d -p  8080:8080 ncrmns/helloworld11"
        ]
        connection {
            type = "ssh"
            host = self.public_ip
            user = "ubuntu"
            private_key = file("${var.privatekey}")
        }
    }
}

