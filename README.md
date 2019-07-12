# EC2 instance with custum user
## 1. Install terraform 
    https://www.terraform.io/downloads.html
## 2. Make a script
### a)(createuser.sh) for user creation with two parameters:
    #!/bin/sh
    
    username=$1
    password=$2
    	
    sudo mkdir /home/$username
    sudo useradd -d /home/$username -s /bin/bash -p $(openssl passwd -1 $password) $username
    sudo groupadd docker
    sudo usermod -aG docker $username

#### in this example we add super user rights for the user to use docker 

### b)(createuser.sh) contain the settings to password authentication, restart the service:

    sudo chmod 777 /etc/ssh/sshd_config
    sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    sudo echo "AllowUsers ubuntu $username" >> /etc/ssh/sshd_config
    sudo chmod 644 /etc/ssh/sshd_config
    sudo systemctl restart ssh

#### We want to login without the use of a .pem file so we change the ssh configuration to let us in
#### with the created users username and  password.
#### To write the config file we escalate our permissions
#### We restart the ssh service for the changes to take effect

## 3. Make main.tf file and contain:
### a)(main.tf) You have to declare the variables:

    variable "username" {
		type = string
    }
    variable "password" {
		type = string
    }
#### Terraform will promt us for these,
#### we can give these variables in a .tfvars file too.

### b)(main.tf) Inside the resource block copy the create user script to the instance:

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

#### For destination use the /tmp folder it doesnt need super user permissions to write.
#### We have to specify the connection, for host we can use self.public_ip if we are in the same
#### block as the instance creation.
#### For user use the username specified by the instance.
#### Use a variable to hide your rout for the .pem file.

### c)(main.tf) ..and give instructions to run it: 

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

#### We have to call our script with the two parameters.

## 4. We can remote acces our instance with the username we gave and its ip:

    ssh <username>@<ip>
