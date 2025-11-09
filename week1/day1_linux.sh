#!/bin/bash
# Week 1 Day 1 – Linux Essentials for DevOps L1 Interviews
# Run: ./week1/day1_linux.sh

clear
echo "=== DevOps L1 – Week 1 Day 1 – $(date '+%Y-%m-%d %H:%M') ==="
echo "System: $(hostname) | Kernel: $(uname -r)"
echo "----------------------------------------------------------"

echo "1. Uptime & Load Average"
uptime

echo -e "\n2. Disk Usage (excluding tmp)"
df -hT | grep -v tmpfs

echo -e "\n3. Memory Usage"
free -h

echo -e "\n4. Top 5 CPU-consuming processes"
ps aux --sort=-%cpu | head -6 | tail -5

echo -e "\n5. Open ports (SSH/HTTP/HTTPS/K8s)"
ss -tuln | grep -E ':22|:80|:443|:8080|:30000' || echo "No common ports"

echo -e "\n6. Interview one-liner: Clean old large logs"
echo "find /var/log -name '*.log' -mtime +30 -size +100M -exec gzip {} \; -delete"

echo -e "\nDay 1 completed successfully. Ready for tomorrow."
