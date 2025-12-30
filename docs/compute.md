# Terraform Compute Module Documentation

## Overview
This document covers the **compute layer** of the 3-tier infra project.  
We have defined **EC2 instances** for **bastion, web, app, and DB tiers** across **multi-AZ**, using **custom AMIs** and **security groups** defined in `security.tf`.

---

## Instance Types

- **Variable:** `var.instance_type`
- **Default:** `t2.micro`
- **Usage:** All EC2 instances (bastion, web, app, DB) use this type.
- **Notes:** Can be upgraded for production workloads.

---

## Key Pairs

- **Bastion (public):** `aws_key_pair.key_bastion` → `key_name = "bastion"`  
- **Private Instances (web/app/db):** `aws_key_pair.key_private` → `key_name = "private"`

**Notes:**  
- Key pairs are stored in `security.tf`.  
- Used for SSH access to EC2s.

---

## Security Groups

- **Bastion:** `aws_security_group.sg_bastion`  
- **Web tier:** `aws_security_group.sg_web`  
- **App tier:** `aws_security_group.sg_app`  
- **DB tier:** `aws_security_group.sg_db`  

**Rules:**  
- Bastion: SSH access from admin IPs.  
- Web: HTTP from ALB, SSH from Bastion.  
- App: HTTP/5000 from Web SG, SSH from Bastion.  
- DB: Custom ports from App SG, SSH if needed from Bastion.

**Notes:**  
- SGs are **stateful**; inbound rules auto-handle return traffic.  
- Tags applied consistently: `tags = { Name = "sg-<tier>" }`

---

## Bastion Host

| Name            | AMI            | Instance Type | Subnet                  | Key Pair        | SG             | Public IP |
|-----------------|----------------|---------------|------------------------|----------------|----------------|-----------|
| ec2-bastion-a   | `var.ami_bastion` | t2.micro     | subnet-public-infra-a  | key_bastion    | sg-bastion     | Yes       |

**Purpose:**  
- Provides secure SSH access to all private EC2s.  
- Located in **public subnet** (AZ-A).

---

## Web Tier EC2s

| Name          | AMI          | Instance Type | Subnet                  | Key Pair     | SG       |
|---------------|--------------|---------------|------------------------|-------------|----------|
| ec2-web-a     | `var.ami_web` | t2.micro     | subnet-private-web-a   | key_private | sg-web   |
| ec2-web-b     | `var.ami_web` | t2.micro     | subnet-private-web-b   | key_private | sg-web   |

**Purpose:**  
- Handles HTTP requests from ALB.  
- Located in **private subnets** across multi-AZ.

---

## App Tier EC2s

| Name          | AMI          | Instance Type | Subnet                  | Key Pair     | SG       |
|---------------|--------------|---------------|------------------------|-------------|----------|
| ec2-app-a     | `var.ami_app` | t2.micro     | subnet-private-app-a   | key_private | sg-app   |
| ec2-app-b     | `var.ami_app` | t2.micro     | subnet-private-app-b   | key_private | sg-app   |

**Purpose:**  
- Runs application logic / Node.js app.  
- Receives traffic from **Web tier** only.  

**Ports:**  
- App listens on `5000` (custom Node app port).  
- SSH allowed from Bastion only.

---

## DB Tier EC2s

| Name          | AMI          | Instance Type | Subnet                  | Key Pair     | SG       |
|---------------|--------------|---------------|------------------------|-------------|----------|
| ec2-db-a      | `var.ami_db`  | t2.micro     | subnet-private-db-a    | key_private | sg-db    |
| ec2-db-b      | `var.ami_db`  | t2.micro     | subnet-private-db-b    | key_private | sg-db    |

**Purpose:**  
- Hosts database (later can migrate to RDS).  
- Receives traffic from **App tier only**.

---

## AMIs

- All EC2s use **custom AMIs built via Packer**:
  - `var.ami_bastion` → Bastion host AMI  
  - `var.ami_web` → Web tier AMI  
  - `var.ami_app` → App tier AMI  
  - `var.ami_db` → DB tier AMI  
- Fetched using **Terraform `data "aws_ami"`** sources if needed.

---

## Subnets

- **Bastion:** public subnet (AZ-A)  
- **Web/App/DB:** private subnets (multi-AZ)  
- Subnet IDs referenced from **network outputs**.

---

## Notes / Best Practices

- Compute layer is **multi-AZ for high availability**.  
- Key pairs and SGs are **centralized in `security.tf`** for reusability.  
- Private EC2s **do not have public IPs**; outbound internet access is via NAT gateways.  
- Naming and tagging conventions follow:  
