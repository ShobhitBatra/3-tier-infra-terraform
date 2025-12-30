#  Security Module (Security Groups and Key Pairs) Documentation

This document describes the security groups, security group rules, and key pairs defined in our Terraform `security.tf` file for a **3-tier architecture** (Web, App, DB) with a Bastion host and ALB.

  ---

## 1\. Key Pairs

### 1.1 Bastion Host Key Pair

`resource "aws_key_pair" "key_bastion" {   key_name   = "bastion"   public_key = file("~/.ssh/bastion.pub") }`

*   **Purpose:** Used to SSH into the Bastion host.
    
*   **Public key location:** `~/.ssh/bastion.pub`
    

### 1.2 Private Instances Key Pair

`resource "aws_key_pair" "key_private" {   key_name   = "private"   public_key = file("~/.ssh/private.pub") }`

*   **Purpose:** Used to SSH into private tier instances (Web, App, DB).
    
*   **Public key location:** `~/.ssh/private.pub`
    

* * *

## 2\. Security Groups (SGs)

### 2.1 ALB Security Group

`resource "aws_security_group" "sg_alb" { ... }`

*   **Name:** `sg-alb`
    
*   **Description:** Security group for the Application Load Balancer (ALB)
    
*   **VPC:** `aws_vpc.vpc_main.id`
    
*   **Tags:** `Name=sg-alb`
    

#### Rules:

1.  **HTTP Ingress**
    

`from_port = 80 to_port   = 80 protocol  = tcp cidr_blocks = ["0.0.0.0/0"]`

*   Allows public HTTP traffic to ALB.
    

2.  **All Outbound**
    

`type = egress from_port = 0 to_port   = 0 protocol  = -1 cidr_blocks = ["0.0.0.0/0"]`

*   Allows ALB to send responses and health check traffic.
    

* * *

### 2.2 Web Tier Security Group

`resource "aws_security_group" "sg_web" { ... }`

*   **Name:** `sg-web`
    
*   **Description:** Security group for Web tier EC2 instances
    
*   **VPC:** `aws_vpc.vpc_main.id`
    
*   **Tags:** `Name=sg-web`
    

#### Rules:

1.  **Allow ALB → Web**
    

`from_port = 80 to_port   = 80 protocol  = tcp source_security_group_id = aws_security_group.sg_alb.id`

2.  **SSH from Bastion**
    

`from_port = 22 to_port   = 22 protocol  = tcp source_security_group_id = aws_security_group.sg_bastion.id`

3.  **All Outbound**
    

`type = egress from_port = 0 to_port   = 0 protocol  = -1 cidr_blocks = ["0.0.0.0/0"]`

*   Allows web instances to initiate outbound connections (App tier, updates, DNS).
    

* * *

### 2.3 App Tier Security Group

`resource "aws_security_group" "sg_app" { ... }`

*   **Name:** `sg-app`
    
*   **Description:** Security group for App tier EC2 instances
    
*   **VPC:** `aws_vpc.vpc_main.id`
    
*   **Tags:** `Name=sg-app`
    

#### Rules:

1.  **Allow Web → App**
    

`from_port = 5000 to_port   = 5000 protocol  = tcp source_security_group_id = aws_security_group.sg_web.id`

2.  **SSH from Bastion**
    

`from_port = 22 to_port   = 22 protocol  = tcp source_security_group_id = aws_security_group.sg_bastion.id`

3.  **All Outbound**
    

`type = egress from_port = 0 to_port   = 0 protocol  = -1 cidr_blocks = ["0.0.0.0/0"]`

* * *

### 2.4 DB Tier Security Group

`resource "aws_security_group" "sg_db" { ... }`

*   **Name:** `sg-db`
    
*   **Description:** Security group for Database tier EC2 instances
    
*   **VPC:** `aws_vpc.vpc_main.id`
    

#### Rules:

1.  **Allow App → DB**
    

`from_port = 3306 to_port   = 3306 protocol  = tcp source_security_group_id = aws_security_group.sg_app.id`

2.  **SSH from Bastion**
    

`from_port = 22 to_port   = 22 protocol  = tcp source_security_group_id = aws_security_group.sg_bastion.id`

3.  **All Outbound**
    

`type = egress from_port = 0 to_port   = 0 protocol  = -1 cidr_blocks = ["0.0.0.0/0"]`

* * *

### 2.5 Bastion Host Security Group

`resource "aws_security_group" "sg_bastion" { ... }`

*   **Name:** `sg-bastion`
    
*   **Description:** Security group for Bastion host
    
*   **VPC:** `aws_vpc.vpc_main.id`
    

#### Rules:

1.  **SSH Ingress (from Internet)**
    

`from_port = 22 to_port   = 22 protocol  = tcp cidr_blocks = ["0.0.0.0/0"]  # Recommend restricting to your IP`

2.  **All Outbound**
    

`type = egress from_port = 0 to_port   = 0 protocol  = -1 cidr_blocks = ["0.0.0.0/0"]`

*   Allows Bastion to initiate connections to private tier instances.
    

* * *

## ✅ Security Flow Summary

| Source | Destination | Port | Notes |
| --- | --- | --- | --- |
| Internet | ALB | 80 | Public HTTP access |
| ALB | Web | 80 | HTTP traffic forwarded to Web tier |
| Bastion | Web/App/DB | 22 | SSH access |
| Web | App | 5000 | Application traffic |
| App | DB | 3306 | Database traffic |
| All tiers | Internet | All | Outbound egress for updates/responses |

* * *

## ⚠️ Notes & Recommendations

1.  **All outbound rules must use `type = egress`**. In the original TF, some were mistakenly set as `ingress`.
    
2.  **Avoid duplicating resource names** in Terraform; each `aws_security_group_rule` must have a unique name.
    
3.  **Bastion HTTP rule removed** — it’s not needed.
    
4.  **DB rule corrected** — only allow App SG, remove `0.0.0.0/0`.
    
5.  **SSH from Internet should be restricted** to your IP for security.
    

* * *

This setup provides a **3-tier secure network** with proper isolation, while allowing necessary communication between tiers.