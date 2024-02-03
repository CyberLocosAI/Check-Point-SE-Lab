output "vpc_details" {
  value = { for i, vpc in aws_vpc.main : vpc.id => {
    id              = vpc.id
    cidr_block      = vpc.cidr_block
    dns_support     = vpc.enable_dns_support
    dns_hostnames   = vpc.enable_dns_hostnames
    internet_gateway = aws_internet_gateway.gw[i].id
    external_subnets = { for subnet in aws_subnet.external : subnet.id => {
        cidr_block  = subnet.cidr_block
        instances   = concat(
          [for instance in aws_instance.vpc_instance : instance.public_ip if instance.subnet_id == subnet.id],
          [for instance in aws_instance.ubuntu_server : instance.public_ip if instance.subnet_id == subnet.id]
        )
      } if subnet.vpc_id == vpc.id
    }
    internal_subnet = {
      id          = aws_subnet.internal[i].id
      cidr_block  = aws_subnet.internal[i].cidr_block
    }
    dmz_subnet = {
      id          = aws_subnet.dmz[i].id
      cidr_block  = aws_subnet.dmz[i].cidr_block
    }
  }}
  description = "Details of each VPC including subnets, EC2 instances, and their public IPs"
}
