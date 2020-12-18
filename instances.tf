#Create and bootstrap wordpress webserver EC2
resource "aws_instance" "wordpress-web" {
  ami                    = "ami-096fda3c22c1c990a"
  instance_type          = var.instance-type
  key_name               = "terraform"
  vpc_security_group_ids = [aws_security_group.wordpress-servers.id]
  subnet_id              = aws_subnet.privsub.id

  tags = {
    Name = "wordpress_web"
  }

  #   #The code below is ONLY the provisioner block which needs to be
  #   #inserted inside the resource block for Jenkins EC2 master Terraform
  #   #Jenkins Master Provisioner:

  #   provisioner "local-exec" {
  #     command = <<EOF
  # aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-master} --instance-ids ${self.id} \
  # && ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' --private-key ~/.ssh/terraform.pem deploy_wordpress_web.yml
  # EOF
  #   }

}

#Create and bootstrap wordpress webdatabase server EC2
resource "aws_instance" "wordpress-data" {
  ami                    = "ami-096fda3c22c1c990a"
  instance_type          = var.instance-type
  key_name               = "terraform"
  vpc_security_group_ids = [aws_security_group.wordpress-servers.id]
  subnet_id              = aws_subnet.privsub.id

  tags = {
    Name = "wordpress_database"
  }

  #The code below is ONLY the provisioner block which needs to be
  #inserted inside the resource block for Jenkins EC2 master Terraform
  #Jenkins Master Provisioner:

  #   provisioner "local-exec" {
  #     command = <<EOF
  # aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-master} --instance-ids ${self.id} \
  # && ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' --private-key ~/.ssh/terraform.pem deploy_wordpress_database.yml
  # EOF
  #   }

}

#Create and bootstrap bastion EC2
resource "aws_instance" "bastion" {
  ami                         = "ami-096fda3c22c1c990a"
  instance_type               = var.instance-type
  key_name                    = "terraform"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion-sg.id]
  subnet_id                   = aws_subnet.pubsub-1.id

  tags = {
    Name = "bastion"
  }

  #The code below is ONLY the provisioner block which needs to be
  #inserted inside the resource block for Jenkins EC2 master Terraform
  #Jenkins Master Provisioner:

  provisioner "local-exec" {
    command = <<EOF
  aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-master} --instance-ids ${self.id} \
  && ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' --private-key ~/.ssh/terraform.pem bastion.yml
  EOF
  }

}