#!/bin/bash
# Week 1 Day 7 – Mini Project: Server Health Monitoring Dashboard
# Run: ./week1/day7_mini_project.sh

clear
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  DevOps L1 – Week 1 Day 7 – MINI PROJECT                      ║"
echo "║  Server Health Monitoring & Alerting System                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "System: $(hostname)"
echo "=================================================================="

# Configuration
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEM=80
ALERT_THRESHOLD_DISK=80
LOG_FILE="/tmp/health_check_$(date +%Y%m%d).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function: Log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# Function: Check CPU Usage
check_cpu() {
    echo -e "\n${YELLOW}[1] CPU HEALTH CHECK${NC}"
    CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d'%' -f1)
    CPU_USAGE=$(echo "100 - $CPU_IDLE" | bc 2>/dev/null || echo "N/A")
    
    if [ "$CPU_USAGE" != "N/A" ]; then
        CPU_USAGE_INT=${CPU_USAGE%.*}
        echo "  CPU Usage: ${CPU_USAGE}%"
        
        if [ $CPU_USAGE_INT -gt $ALERT_THRESHOLD_CPU ]; then
            echo -e "  ${RED}⚠️  ALERT: CPU usage above threshold!${NC}"
            log_message "ALERT: CPU usage at ${CPU_USAGE}%"
        else
            echo -e "  ${GREEN}✅ CPU is healthy${NC}"
        fi
    fi
}

# Function: Check Memory Usage
check_memory() {
    echo -e "\n${YELLOW}[2] MEMORY HEALTH CHECK${NC}"
    MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
    MEM_USED=$(free -m | awk '/^Mem:/ {print $3}')
    MEM_PERCENT=$(echo "scale=2; $MEM_USED * 100 / $MEM_TOTAL" | bc)
    MEM_PERCENT_INT=${MEM_PERCENT%.*}
    
    echo "  Memory: ${MEM_USED}MB / ${MEM_TOTAL}MB (${MEM_PERCENT}%)"
    
    if [ $MEM_PERCENT_INT -gt $ALERT_THRESHOLD_MEM ]; then
        echo -e "  ${RED}⚠️  ALERT: Memory usage high!${NC}"
        log_message "ALERT: Memory usage at ${MEM_PERCENT}%"
    else
        echo -e "  ${GREEN}✅ Memory is healthy${NC}"
    fi
}

# Function: Check Disk Usage
check_disk() {
    echo -e "\n${YELLOW}[3] DISK HEALTH CHECK${NC}"
    df -h | grep '^/dev/' | while read line; do
        PARTITION=$(echo $line | awk '{print $1}')
        USAGE=$(echo $line | awk '{print $5}' | sed 's/%//')
        MOUNT=$(echo $line | awk '{print $6}')
        
        echo "  $MOUNT: ${USAGE}% used"
        
        if [ $USAGE -gt $ALERT_THRESHOLD_DISK ]; then
            echo -e "  ${RED}⚠️  ALERT: Disk usage high on $MOUNT${NC}"
            log_message "ALERT: Disk usage at ${USAGE}% on $MOUNT"
        fi
    done
}

# Function: Check Services
check_services() {
    echo -e "\n${YELLOW}[4] SERVICE HEALTH CHECK${NC}"
    SERVICES=("sshd" "docker" "cron")
    
    for service in "${SERVICES[@]}"; do
        if systemctl is-active --quiet $service 2>/dev/null; then
            echo -e "  ${GREEN}✅ $service: Running${NC}"
        else
            echo -e "  ${RED}❌ $service: Not running${NC}"
            log_message "ALERT: Service $service is down"
        fi
    done
}

# Function: Check Network Connectivity
check_network() {
    echo -e "\n${YELLOW}[5] NETWORK CONNECTIVITY${NC}"
    
    if ping -c 2 8.8.8.8 >/dev/null 2>&1; then
        echo -e "  ${GREEN}✅ Internet: Connected${NC}"
    else
        echo -e "  ${RED}❌ Internet: Disconnected${NC}"
        log_message "ALERT: No internet connectivity"
    fi
    
    # Check DNS
    if nslookup google.com >/dev/null 2>&1; then
        echo -e "  ${GREEN}✅ DNS: Resolving${NC}"
    else
        echo -e "  ${RED}❌ DNS: Failed${NC}"
        log_message "ALERT: DNS resolution failed"
    fi
}

# Function: Check Open Ports
check_ports() {
    echo -e "\n${YELLOW}[6] SECURITY PORT SCAN${NC}"
    CRITICAL_PORTS=(22 80 443)
    
    for port in "${CRITICAL_PORTS[@]}"; do
        if ss -tuln | grep -q ":$port "; then
            echo -e "  ${GREEN}✅ Port $port: Open${NC}"
        else
            echo "  ℹ️  Port $port: Closed"
        fi
    done
}

# Function: Generate Report Summary
generate_summary() {
    echo -e "\n${YELLOW}[7] SYSTEM SUMMARY${NC}"
    echo "  Hostname: $(hostname)"
    echo "  Uptime: $(uptime -p)"
    echo "  Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo "  Kernel: $(uname -r)"
    echo "  IP Address: $(hostname -I | awk '{print $1}')"
    echo "  Log file: $LOG_FILE"
}

# Function: Export Metrics (Prometheus format)
export_metrics() {
    echo -e "\n${YELLOW}[8] PROMETHEUS METRICS${NC}"
    cat << EOF
# HELP node_cpu_usage CPU usage percentage
# TYPE node_cpu_usage gauge
node_cpu_usage{hostname="$(hostname)"} $(echo "100 - $(top -bn1 | grep 'Cpu(s)' | awk '{print $8}' | cut -d'%' -f1)" | bc 2>/dev/null || echo 0)

# HELP node_memory_usage Memory usage percentage  
# TYPE node_memory_usage gauge
node_memory_usage{hostname="$(hostname)"} $(free | awk '/^Mem:/ {print $3/$2 * 100}')

# HELP node_disk_usage Disk usage percentage
# TYPE node_disk_usage gauge
node_disk_usage{hostname="$(hostname)",mount="/"} $(df / | tail -1 | awk '{print $5}' | sed 's/%//')
EOF
}

# Main Execution
log_message "=== Health Check Started ==="

check_cpu
check_memory
check_disk
check_services
check_network
check_ports
generate_summary
export_metrics

log_message "=== Health Check Completed ==="

echo ""
echo "=================================================================="
echo -e "${GREEN}✅ Week 1 Mini Project Completed!${NC}"
echo "=================================================================="
echo ""
echo "📊 Next Steps:"
echo "  1. Schedule this script with cron (every 5 mins)"
echo "     Example: */5 * * * * /path/to/day7_mini_project.sh"
echo "  2. Send alerts via email/Slack webhook"
echo "  3. Push metrics to Prometheus/Datadog"
echo "  4. Visualize in Grafana dashboard"
echo ""
echo "📚 Week 1 Topics Covered:"
echo "  ✓ Linux fundamentals & system administration"
echo "  ✓ User management & permissions"
echo "  ✓ Networking & troubleshooting"
echo "  ✓ Bash scripting & automation"
echo "  ✓ System monitoring & performance"
echo "  ✓ Security hardening & best practices"
echo "  ✓ Infrastructure health monitoring"
echo ""
echo "🎯 DevOps Skills Demonstrated:"
echo "  ✓ Good scripting skills (Bash)"
echo "  ✓ Monitoring and alerting implementation"
echo "  ✓ Infrastructure management knowledge"
echo "  ✓ Security and networking concepts"
echo "  ✓ Production-ready code practices"
echo ""
echo "🚀 Week 2 Preview: Git + GitOps"
echo "  - Git workflows & best practices"
echo "  - GitHub Actions / Bitbucket Pipelines"
echo "  - GitOps principles (ArgoCD, Flux)"
echo "  - Code review & collaboration"
echo ""
