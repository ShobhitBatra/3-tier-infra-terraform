# Network Module Documentation

## Overview
This document covers the **network layer** of the 3-tier infra project.  
We have designed a **multi-AZ VPC** with **public and private subnets**, **NAT gateways**, and **route tables** following production-grade patterns.

---

## VPC

- **Resource Name:** `aws_vpc.vpc_main`
- **CIDR Block:** `192.168.0.0/24`
- **Description:** Main VPC for the project.
- **Tags:** `Name = vpc-main`
- **Notes:** CIDR is kept small to enforce correctness in subnetting.

---

## Availability Zones

- **Variable:** `var.availability_zones`
- **Type:** `list(string)`
- **Values:** `["ap-south-1a", "ap-south-1b"]`
- **Usage:** Each AZ hosts a public subnet, private web, app, and DB subnets.

---

## Public Subnets

| Name | CIDR | AZ | map_public_ip_on_launch |
|------|------|----|------------------------|
| subnet-public-infra-a | 192.168.0.0/27 | ap-south-1a | true |
| subnet-public-infra-b | 192.168.0.32/27 | ap-south-1b | true |

- **Purpose:** Host ALB and NAT gateways.
- **Tagging convention:** `subnet-public-infra-a`, `subnet-public-infra-b`

---

## Private Subnets

### Web Tier

| Name | CIDR | AZ |
|------|------|----|
| subnet-private-web-a | 192.168.0.64/27 | ap-south-1a |
| subnet-private-web-b | 192.168.0.96/27 | ap-south-1b |

### App Tier

| Name | CIDR | AZ |
|------|------|----|
| subnet-private-app-a | 192.168.0.128/27 | ap-south-1a |
| subnet-private-app-b | 192.168.0.160/27 | ap-south-1b |

### DB Tier

| Name | CIDR | AZ |
|------|------|----|
| subnet-private-db-a | 192.168.0.192/27 | ap-south-1a |
| subnet-private-db-b | 192.168.0.224/27 | ap-south-1b |

- **Purpose:** Host EC2 instances for web, app, and DB tiers.
- **Tagging convention:** `subnet-private-web-a`, `subnet-private-app-b`, etc.

---

## Internet Gateway

- **Resource Name:** `aws_internet_gateway.igw_main`
- **VPC:** `vpc_main`
- **Tags:** `igw-main`
- **Purpose:** Provides internet access to public subnets.

---

## NAT Gateways

- **AZ-A NAT**
  - EIP: `aws_eip.eip_nat_a`
  - NAT: `aws_nat_gateway.nat_gw_public_infra_a`
  - Subnet: Public subnet in AZ-A
- **AZ-B NAT**
  - EIP: `aws_eip.eip_nat_b`
  - NAT: `aws_nat_gateway.nat_gw_public_infra_b`
  - Subnet: Public subnet in AZ-B

**Purpose:** Private subnets route internet-bound traffic through their AZ-specific NAT for high availability.

---

## Route Tables

### Public

- **Resource:** `aws_route_table.rt_public`
- **Route:** `0.0.0.0/0 → IGW`
- **Associated Subnets:** Public infra subnets (AZ-A & B)

### Private

- **AZ-A:** `aws_route_table.rt_private_a` → NAT-A
- **AZ-B:** `aws_route_table.rt_private_b` → NAT-B
- **Associated Subnets:** Web, App, DB subnets in corresponding AZ

**Reasoning:** Keeps traffic within AZ for NAT and high availability.

---

## Route Table Associations

- **Public:** `rta_public_infra_a`, `rta_public_infra_b`
- **Private:** Each private subnet associated with its AZ-specific private route table
- **Naming convention:** `<rta>_<subnet_tier>_<az>`

---

## Outputs

```hcl
output "vpc_id" { value = aws_vpc.vpc_main.id }
output "public_subnet_ids" { value = [aws_subnet.subnet_public_infra_a.id, aws_subnet.subnet_public_infra_b.id] }
output "private_subnet_ids" {
  value = [
    aws_subnet.subnet_private_web_a.id,
    aws_subnet.subnet_private_web_b.id,
    aws_subnet.subnet_private_app_a.id,
    aws_subnet.subnet_private_app_b.id,
    aws_subnet.subnet_private_db_a.id,
    aws_subnet.subnet_private_db_b.id
  ]
}
```

## Summary

- Multi-AZ, production-ready network setup.
- Public subnets: ALB and NAT gateways.
- Private subnets: web, app, DB EC2s.
- Route tables: AZ-specific private routes, single public route table.
- Naming and tagging conventions applied consistently.
- Fully modular-ready for compute and app layers.