#!/bin/bash
# Week 1 Day 6 – Security & Networking Concepts for DevOps
# Run: ./week1/day6_security.sh

clear
echo "=== DevOps L1 – Week 1 Day 6 – $(date '+%Y-%m-%d %H:%M') ==="
echo "Topic: Security Hardening & Network Security"
echo "--------------------------------------------------------------------"

echo "1. User Security Audit"
echo "  Total users: $(wc -l < /etc/passwd)"
echo "  Users with login shell:"
grep -v '/nologin\|/false' /etc/passwd | awk -F: '{print "    " $1 " (UID: " $3 ")"}' | head -5
echo "  Sudo users:"
grep -Po '^sudo.+:\K.*$' /etc/group 2>/dev/null || echo "    Cannot read group file"

echo -e "\n2. SSH Security Configuration"
if [ -f /etc/ssh/sshd_config ]; then
    echo "  Checking SSH hardening:"
    grep -E "^PermitRootLogin|^PasswordAuthentication|^Port" /etc/ssh/sshd_config 2>/dev/null | \
        awk '{print "    " $0}' || echo "    Cannot read SSH config"
else
    echo "    SSH config not found"
fi

echo -e "\n3. Open Ports & Security Risk Assessment"
echo "  Listening ports:"
ss -tuln | grep LISTEN | awk '{print $5}' | sed 's/.*://' | sort -n | uniq | while read port; do
    case $port in
        22) echo "    Port $port (SSH) - ✅ Standard" ;;
        80) echo "    Port $port (HTTP) - ⚠️  Consider HTTPS only" ;;
        443) echo "    Port $port (HTTPS) - ✅ Secure" ;;
        3306) echo "    Port $port (MySQL) - ⚠️  Should not be public" ;;
        5432) echo "    Port $port (PostgreSQL) - ⚠️  Should not be public" ;;
        6379) echo "    Port $port (Redis) - ⚠️  Should not be public" ;;
        *) echo "    Port $port - ℹ️  Review necessity" ;;
    esac
done

echo -e "\n4. Failed Login Attempts (Security Monitoring)"
echo "  Recent failed SSH attempts:"
if [ -r /var/log/auth.log ]; then
    sudo grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 | \
        awk '{print "    " $1, $2, $3, $11}' || echo "    No recent failures or need sudo"
elif [ -r /var/log/secure ]; then
    sudo grep "Failed password" /var/log/secure 2>/dev/null | tail -5 | \
        awk '{print "    " $1, $2, $3, $11}' || echo "    No recent failures or need sudo"
else
    echo "    Auth logs not accessible"
fi

echo -e "\n5. File Permissions Security"
echo "  SUID files (potential security risk if misconfigured):"
find /usr/bin /usr/sbin -type f -perm -4000 2>/dev/null | head -5 | while read file; do
    echo "    $(ls -l $file | awk '{print $1, $3, $9}')"
done
echo "    ... (showing first 5 only)"

echo -e "\n6. Firewall Configuration"
if command -v ufw &> /dev/null; then
    echo "  UFW (Uncomplicated Firewall):"
    sudo ufw status verbose 2>/dev/null | head -10 | sed 's/^/    /' || echo "    Need sudo or inactive"
elif command -v firewall-cmd &> /dev/null; then
    echo "  Firewalld:"
    sudo firewall-cmd --list-all 2>/dev/null | head -10 | sed 's/^/    /' || echo "    Need sudo or inactive"
else
    echo "  ⚠️  No firewall detected - Security risk!"
fi

echo -e "\n7. Network Security Groups (NSG) Simulation"
cat << 'EOF'
# AWS Security Group Example (Terraform)
resource "aws_security_group" "web_server" {
  name = "web-server-sg"
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTPS from anywhere
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # SSH from internal only
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # All outbound
  }
}
EOF

echo -e "\n8. SSL/TLS Certificate Check"
cat << 'EOF'
#!/bin/bash
# check_ssl.sh - Verify SSL certificate expiry

DOMAIN="example.com"
EXPIRY=$(echo | openssl s_client -connect $DOMAIN:443 2>/dev/null | \
         openssl x509 -noout -enddate | cut -d= -f2)
echo "SSL expires: $EXPIRY"

# Check if expiring in 30 days
EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $NOW_EPOCH) / 86400 ))

if [ $DAYS_LEFT -lt 30 ]; then
    echo "⚠️  SSL certificate expires in $DAYS_LEFT days!"
fi
EOF

echo -e "\n9. Security Best Practices Checklist"
echo "  ✓ Principle of Least Privilege (minimal permissions)"
echo "  ✓ Regular security updates (apt update && apt upgrade)"
echo "  ✓ Strong password policies (complexity, rotation)"
echo "  ✓ Multi-Factor Authentication (MFA) for critical access"
echo "  ✓ Encryption at rest and in transit (SSL/TLS)"
echo "  ✓ Regular security audits and penetration testing"
echo "  ✓ Log monitoring and SIEM integration"
echo "  ✓ Network segmentation (VPC, subnets, security groups)"

echo -e "\n10. Common Security Vulnerabilities"
echo "  • Open ports (unnecessary services exposed)"
echo "  • Weak credentials (default passwords)"
echo "  • Unpatched systems (CVE vulnerabilities)"
echo "  • Misconfigured permissions (overly permissive)"
echo "  • Lack of encryption (data in transit)"
echo "  • No audit logging (blind spots)"

echo -e "\n📚 Security Resources for DevOps:"
echo "  1. OWASP Top 10: https://owasp.org/www-project-top-ten/"
echo "  2. CIS Benchmarks: https://www.cisecurity.org/cis-benchmarks/"
echo "  3. AWS Security: https://aws.amazon.com/security/best-practices/"
echo "  4. Linux Hardening: https://linux-audit.com/linux-security-guide/"
echo "  5. DevSecOps: https://www.devsecops.org/blog/2015/2/15/what-is-devsecops"

echo -e "\n🎯 Interview Security Questions:"
echo "  Q1: How to secure a production server?"
echo "      A: Firewall, SSH keys only, disable root login, updates, monitoring"
echo "  Q2: Difference between symmetric and asymmetric encryption?"
echo "      A: Symmetric uses same key, asymmetric uses public/private key pair"
echo "  Q3: What is Zero Trust Architecture?"
echo "      A: Never trust, always verify - authenticate every request"
echo "  Q4: How to detect a compromised system?"
echo "      A: Monitor logs, unusual processes, network traffic, file integrity"

echo -e "\n💡 Real-world Security Incident Response:"
echo "  1. Identify: Detect the security incident"
echo "  2. Contain: Isolate affected systems"
echo "  3. Eradicate: Remove threat completely"
echo "  4. Recover: Restore systems to normal"
echo "  5. Lessons: Document and improve processes"

echo -e "\n✅ Day 6 completed: Security & Networking fundamentals"
