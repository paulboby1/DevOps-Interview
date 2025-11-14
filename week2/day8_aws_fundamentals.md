# Week 2 Day 8 – AWS Fundamentals for DevOps

## What is AWS?

Amazon Web Services (AWS) is the world’s leading cloud platform, offering on-demand compute, storage, networking, and many other services. It allows you to run applications and manage infrastructure without owning physical servers.

---

## Why Learn AWS for DevOps?

- Automate infrastructure (servers, storage, networking) as code
- Scale applications globally
- Integrate with CI/CD, monitoring, and security tools

---

## Core AWS Concepts

### 1. **Region**

A physical location in the world (e.g., `us-east-1`, `ap-south-1`). Each region contains multiple Availability Zones.

### 2. **Availability Zone (AZ)**

One or more data centers in a region. Used for high availability and fault tolerance.

### 3. **VPC (Virtual Private Cloud)**

Your own private network in AWS. You control IP ranges, subnets, routing, and security.

---

## Key AWS Services for DevOps

| Service            | What it does                 | Example Use                |
| ------------------ | ---------------------------- | -------------------------- |
| **EC2**            | Virtual servers (compute)    | Run web apps, databases    |
| **S3**             | Object storage               | Store files, backups, logs |
| **IAM**            | Identity & Access Management | Control user permissions   |
| **RDS**            | Managed databases            | MySQL, PostgreSQL, etc.    |
| **Lambda**         | Serverless compute           | Run code without servers   |
| **CloudWatch**     | Monitoring & logging         | Metrics, logs, alarms      |
| **CloudFormation** | Infrastructure as Code       | Automate AWS resources     |

---

## AWS Free Tier

Many services are free for 12 months (limited usage).  
[See AWS Free Tier](https://aws.amazon.com/free/)

---

## How to Access AWS

- **AWS Console:** Web UI for managing resources
- **AWS CLI:** Command-line tool for automation
- **SDKs:** Use AWS in Python, Go, Java, etc.

---

## Learning Resources

- [AWS Cloud Practitioner Essentials (Free)](https://explore.skillbuilder.aws/learn/course/13461/aws-cloud-practitioner-essentials)
- [AWS Getting Started Tutorials](https://aws.amazon.com/getting-started/hands-on/)
- [AWS Official Documentation](https://docs.aws.amazon.com/)

---

## Practice Questions

1. What is an AWS Region?
2. What is the difference between EC2 and S3?
3. How does IAM help with security?
4. What is the AWS Free Tier?

---

**Next:**

- Day 9: Launching your first EC2 instance (theory + CLI)
- Day 10: S3 buckets and permissions
