provider "aws" {
	region = var.aws_region
}


resource "aws_vpc" "vpc" { 
	cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gateway" {
	vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route" "internet_access" {
	route_table_id = aws_vpc.vpc.main_route_table_id
	destination_cidr_block = "0.0.0.0/0"
	gateway_id = aws_internet_gateway.gateway.id
}

resource "aws_subnet" "subnet" {
	vpc_id = aws_vpc.vpc.id
	cidr_block = "10.0.0.0/24"
	map_public_ip_on_launch = true
}

resource "aws_security_group" "elb_sg" { 
	name = "elb-sg"
	vpc_id = aws_vpc.vpc.id

	ingress {
                from_port = 80
                to_port = 80
                protocol = "tcp"
                cidr_blocks = [ "0.0.0.0/0" ]
        }

	egress { 
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = [ "0.0.0.0/0" ]
        }

}


resource "aws_security_group" "instance_sg" { 
	name = "ubuntu-sg"
	vpc_id = "${aws_vpc.vpc.id}"

	ingress { 
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = var.cidrs
	}

	ingress {
                from_port = 80
                to_port = 80
                protocol = "tcp"
                cidr_blocks = [ "10.0.0.0/16" ]
        }

	egress { 
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = [ "0.0.0.0/0" ]
        }

}

resource "aws_elb" "elb" {
	name = "elb-new"
	subnets = [ aws_subnet.subnet.id ]
	security_groups = [ aws_security_group.elb_sg.id ]
	instances = [ aws_instance.example.id ]

	listener {
		instance_port = 4000
		instance_protocol = "http"
		lb_port = 80
		lb_protocol = "http"
	}
	
} 

resource "aws_instance" "example" {

	tags = {
		Name = "lab-instance-new"
	}
	ami = var.ami_id
	instance_type = var.ec2_instance_type
	key_name = var.key_name

	iam_instance_profile = var.role

	depends_on = [aws_internet_gateway.gateway]	

	associate_public_ip_address = true

	subnet_id = aws_subnet.subnet.id
	vpc_security_group_ids = [
		aws_security_group.instance_sg.id
	]

	connection {
		user = "ubuntu"
		host = self.public_ip
	}

#	user_data = <<-EOF
		#!/bin/bash
#		echo "Hello world" > index.html
#		nohup busybox httpd -f -p 80 &
#		EOF

}

resource "aws_codedeploy_app" "deploy_app" {
	name = "lab-app-new"
}


resource "aws_codedeploy_deployment_group" "deploy_group" {
        app_name = aws_codedeploy_app.deploy_app.name
	deployment_group_name = "lab-group-new"
	service_role_arn = var.arn
	

	load_balancer_info {
		elb_info {
			name = aws_elb.elb.name
		}
	}

	ec2_tag_set {
		ec2_tag_filter {
			key = "Name"
			type = "KEY_AND_VALUE"
			value = "lab-instance-new"
		}
	}
}

resource "aws_s3_bucket" "bucket" {
	bucket = "tema-cloud-lab-bucket"
	
	website {
		index_document = "index.html"
	}

	tags =  {
		Name = "Code bucket"
	}

}
