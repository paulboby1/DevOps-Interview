#!/bin/bash
# Week 1 Day 3 – Linux Networking & Troubleshooting
# Run: ./week1/day3_linux.sh

clear
echo "=== DevOps L1 – Week 1 Day 3 – $(date '+%Y-%m-%d %H:%M') ==="
echo "System: $(hostname) | IP: $(hostname -I | awk '{print $1}')"
echo "----------------------------------------------------------"

echo "1. Network Interfaces"
ip -br addr show | grep -v lo || ifconfig -a | grep -E 'inet|flags'
echo ""

echo "2. Active Network Connections"
echo "Established connections:"
ss -tuln | grep ESTAB | head -5 || echo "  No established connections"
echo "Listening ports:"
ss -tuln | grep LISTEN | head -5

echo -e "\n3. DNS Resolution Test"
echo "Resolving google.com:"
nslookup google.com 2>/dev/null | grep -A1 "Name:" | head -3 || echo "  nslookup not available"

echo -e "\n4. Network Connectivity Test"
echo "Ping test to 8.8.8.8:"
ping -c 3 8.8.8.8 2>/dev/null | grep -E 'bytes from|packet loss' || echo "  Ping failed or not permitted"

echo -e "\n5. Routing Table"
echo "Default gateway:"
ip route | grep default || route -n | grep UG

echo -e "\n6. Network Statistics"
echo "Network interface stats (RX/TX packets):"
cat /proc/net/dev | grep -E 'eth0|ens|wlan|wlp' | head -3 || echo "  Interface stats not available"

echo -e "\n7. Open Ports Check (Common Services)"
echo "Checking common ports:"
for port in 22 80 443 3000 8080 9090; do
    if ss -tuln | grep -q ":$port "; then
        echo "  Port $port: OPEN"
    else
        echo "  Port $port: closed"
    fi
done

echo -e "\n8. Firewall Status"
if command -v ufw &> /dev/null; then
    echo "UFW Status:"
    sudo ufw status 2>/dev/null || echo "  Cannot check UFW (need sudo)"
elif command -v firewall-cmd &> /dev/null; then
    echo "Firewalld Status:"
    sudo firewall-cmd --state 2>/dev/null || echo "  Cannot check firewalld (need sudo)"
else
    echo "No common firewall detected (ufw/firewalld)"
fi

echo -e "\n9. Network Troubleshooting Commands:"
echo "  netstat -tulpn - Show listening ports with programs"
echo "  ss -s - Socket statistics summary"
echo "  tcpdump -i any port 80 - Capture HTTP traffic"
echo "  traceroute google.com - Trace route to destination"
echo "  nc -zv host port - Test if port is open"
echo "  curl -I https://site.com - Check HTTP headers"

echo -e "\n10. Interview one-liners:"
echo "# Check which process uses port 8080: lsof -i :8080"
echo "# Show all network connections: netstat -antp"
echo "# Test port connectivity: telnet host port OR nc -zv host port"
echo "# Download file: wget URL OR curl -O URL"
echo "# Check DNS: dig domain.com OR nslookup domain.com"

echo -e "\n11. Performance Check"
echo "Network throughput (approximate):"
cat /sys/class/net/$(ip route | grep default | awk '{print $5}' | head -1)/speed 2>/dev/null && echo "Mbps" || echo "  Speed info not available"

echo -e "\nDay 3 completed successfully. Key topics: Networking, Connectivity, Troubleshooting."
