locals {
	this_public_ip = compact(coalescelist(aws_instance.example.*.public_ip, [""]))
}

output "ips" {
	value = aws_instance.example.*.public_ip
}
