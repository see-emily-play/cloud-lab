variable "key_name" {
	default = "server-key"
}

variable "key_path" {
	default = "~/cloud-lab/sshkey/server-key.pem"
}

variable "arn" {
	default = "arn:aws:iam::789330820382:role/deploy-role"
}

variable "role" {
        default = "EC2InstanceRole"
}


variable "project_name" {
	default = "cloud-lab"
}

variable "ec2_instance_type" {
	default = "t2.micro"
}

variable "ec2_ssh_user" {
	default = "ubuntu"
}

variable "aws_region" {
	default = "eu-central-1"
}

variable "ami_id" {
	default = "ami-05f7491af5eef733a"
}

variable "cidrs" { 
	type = list
	default = [
		"31.134.191.180/32"		
	]
}

