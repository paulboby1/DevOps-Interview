#!/bin/bash
# Week 1 Day 4 – Bash Scripting for DevOps Automation
# Run: ./week1/day4_bash_scripting.sh

clear
echo "=== DevOps L1 – Week 1 Day 4 – $(date '+%Y-%m-%d %H:%M') ==="
echo "Topic: Bash Scripting Fundamentals for Infrastructure Automation"
echo "--------------------------------------------------------------------"

# 1. Variables and Command Substitution
echo "1. Variables & Command Substitution"
SERVER_NAME=$(hostname)
CURRENT_DATE=$(date '+%Y-%m-%d')
UPTIME_DAYS=$(uptime -p)
echo "  Server: $SERVER_NAME"
echo "  Date: $CURRENT_DATE"
echo "  Uptime: $UPTIME_DAYS"

# 2. Conditional Statements (if-else)
echo -e "\n2. Health Check (if-else logic)"
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "  ⚠️  ALERT: Disk usage is ${DISK_USAGE}% (threshold: 80%)"
else
    echo "  ✅ OK: Disk usage is ${DISK_USAGE}% (healthy)"
fi

# 3. Loops (for loop)
echo -e "\n3. Checking Multiple Services (for loop)"
SERVICES=("docker" "ssh" "cron")
for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet $service 2>/dev/null; then
        echo "  ✅ $service is running"
    else
        echo "  ❌ $service is not running or doesn't exist"
    fi
done

# 4. Functions
echo -e "\n4. Reusable Functions"
check_port() {
    local port=$1
    if ss -tuln | grep -q ":$port "; then
        echo "  ✅ Port $port: OPEN"
    else
        echo "  ❌ Port $port: CLOSED"
    fi
}

check_port 22
check_port 80
check_port 443

# 5. Arrays
echo -e "\n5. Log File Analysis (arrays)"
LOG_LEVELS=("ERROR" "WARNING" "INFO")
echo "  Searching system logs for:"
for level in "${LOG_LEVELS[@]}"; do
    COUNT=$(journalctl -p err -n 100 2>/dev/null | grep -ci "$level" || echo "0")
    echo "    $level: $COUNT occurrences"
done

# 6. File Operations
echo -e "\n6. Automated Backup Simulation"
BACKUP_DIR="/tmp/devops_backup_$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR
echo "Sample config" > $BACKUP_DIR/config.txt
echo "  ✅ Backup created at: $BACKUP_DIR"
ls -lh $BACKUP_DIR

# 7. Error Handling
echo -e "\n7. Error Handling with Exit Codes"
test_command() {
    ping -c 1 8.8.8.8 >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "  ✅ Network connectivity: OK"
        return 0
    else
        echo "  ❌ Network connectivity: FAILED"
        return 1
    fi
}
test_command

# 8. String Manipulation
echo -e "\n8. String Operations"
VERSION="v1.2.3-beta"
echo "  Original: $VERSION"
echo "  Uppercase: ${VERSION^^}"
echo "  Without 'beta': ${VERSION%-beta}"
echo "  Length: ${#VERSION} characters"

# 9. Case Statement
echo -e "\n9. Environment Detection (case statement)"
ENV_TYPE="production"
case $ENV_TYPE in
    development)
        echo "  🔧 Development environment - Debug mode ON"
        ;;
    staging)
        echo "  🧪 Staging environment - Testing mode"
        ;;
    production)
        echo "  🚀 Production environment - High availability mode"
        ;;
    *)
        echo "  ❓ Unknown environment"
        ;;
esac

# 10. Real-world DevOps Script Example
echo -e "\n10. Complete Health Check Script Example"
cat << 'EOF'
#!/bin/bash
# health_check.sh - Production server health monitoring

check_service() {
    systemctl is-active --quiet $1 && echo "✅ $1" || echo "❌ $1"
}

echo "=== Health Check Report ==="
echo "Date: $(date)"
echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
echo "CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
check_service docker
check_service nginx
EOF

echo -e "\n📚 Learning Resources for DevOps Interviews:"
echo "  1. Bash Scripting: https://www.shellscript.sh/"
echo "  2. Advanced Bash: https://tldp.org/LDP/abs/html/"
echo "  3. DevOps Scripts: https://github.com/awesome-lists/awesome-bash"
echo "  4. Best Practices: https://google.github.io/styleguide/shellguide.html"

echo -e "\n🎯 Interview Practice Questions:"
echo "  Q1: How do you handle errors in bash scripts? (Answer: set -e, $?, trap)"
echo "  Q2: Difference between [ ] and [[ ]]? (Answer: [[ ]] is bash-specific, more powerful)"
echo "  Q3: How to make scripts idempotent? (Answer: Check state before actions)"
echo "  Q4: How to pass arguments to a script? (Answer: \$1, \$2, \$@, \$#)"

echo -e "\n✅ Day 4 completed: Bash scripting fundamentals for automation"
