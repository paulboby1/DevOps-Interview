#!/bin/bash
# Week 1 Day 5 – System Monitoring & Performance Tuning
# Run: ./week1/day5_monitoring.sh

clear
echo "=== DevOps L1 – Week 1 Day 5 – $(date '+%Y-%m-%d %H:%M') ==="
echo "Topic: Infrastructure Monitoring & Performance Analysis"
echo "--------------------------------------------------------------------"

echo "1. CPU Monitoring & Load Average"
echo "  Current load: $(uptime | awk -F'load average:' '{print $2}')"
echo "  CPU cores: $(nproc)"
LOAD_1MIN=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | tr -d ' ')
echo "  Load per core: $(echo "scale=2; $LOAD_1MIN / $(nproc)" | bc 2>/dev/null || echo "N/A")"

echo -e "\n2. Memory Analysis (Critical for Production)"
free -h
MEM_PERCENT=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
echo "  Memory usage: ${MEM_PERCENT}%"
if [ $MEM_PERCENT -gt 80 ]; then
    echo "  ⚠️  HIGH MEMORY USAGE - Consider scaling!"
fi

echo -e "\n3. Disk I/O Performance"
echo "  Disk usage summary:"
df -h | grep -E '^/dev/' | awk '{print "    " $1 ": " $5 " used (" $3 "/" $2 ")"}'

echo -e "\n4. Top 5 Memory-Consuming Processes"
ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "  %s: %.1f%% (PID: %s)\n", $11, $4, $2}'

echo -e "\n5. Top 5 CPU-Consuming Processes"
ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "  %s: %.1f%% (PID: %s)\n", $11, $3, $2}'

echo -e "\n6. Network Interface Metrics"
for iface in $(ip -o link show | awk -F': ' '{print $2}' | grep -v lo); do
    RX_BYTES=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null)
    TX_BYTES=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null)
    if [ ! -z "$RX_BYTES" ]; then
        RX_MB=$(echo "scale=2; $RX_BYTES / 1024 / 1024" | bc)
        TX_MB=$(echo "scale=2; $TX_BYTES / 1024 / 1024" | bc)
        echo "  $iface: RX ${RX_MB}MB | TX ${TX_MB}MB"
    fi
done

echo -e "\n7. System Resource Limits"
echo "  Max open files: $(ulimit -n)"
echo "  Max processes: $(ulimit -u)"
echo "  Max file size: $(ulimit -f)"

echo -e "\n8. Service Health Checks"
CRITICAL_SERVICES=("sshd" "docker" "cron")
for service in "${CRITICAL_SERVICES[@]}"; do
    if systemctl is-active --quiet $service 2>/dev/null; then
        UPTIME=$(systemctl show $service --property=ActiveEnterTimestamp --value 2>/dev/null)
        echo "  ✅ $service: Active (since: ${UPTIME:-unknown})"
    else
        echo "  ❌ $service: Inactive or not found"
    fi
done

echo -e "\n9. Log Monitoring (Error Detection)"
echo "  Recent system errors (last 10):"
journalctl -p err -n 10 --no-pager 2>/dev/null | tail -10 || echo "  Cannot access system logs"

echo -e "\n10. Performance Metrics Collection Script"
cat << 'EOF'
#!/bin/bash
# metrics_collector.sh - Export metrics for monitoring systems

# Prometheus-style metrics
echo "# HELP node_memory_usage Memory usage percentage"
echo "# TYPE node_memory_usage gauge"
MEM=$(free | grep Mem | awk '{print $3/$2 * 100}')
echo "node_memory_usage $MEM"

echo "# HELP node_disk_usage Disk usage percentage"
echo "# TYPE node_disk_usage gauge"
DISK=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
echo "node_disk_usage $DISK"

echo "# HELP node_cpu_load CPU load average (1min)"
echo "# TYPE node_cpu_load gauge"
LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}')
echo "node_cpu_load $LOAD"
EOF

echo -e "\n📚 Monitoring Tools & Resources:"
echo "  1. Prometheus: https://prometheus.io/docs/introduction/overview/"
echo "  2. Grafana: https://grafana.com/docs/grafana/latest/getting-started/"
echo "  3. Datadog: https://docs.datadoghq.com/getting_started/"
echo "  4. NewRelic: https://docs.newrelic.com/docs/new-relic-solutions/get-started/intro-new-relic/"
echo "  5. Node Exporter: https://github.com/prometheus/node_exporter"

echo -e "\n🎯 DevOps Interview Topics:"
echo "  ✓ Metrics vs Logs vs Traces"
echo "  ✓ SLI, SLO, SLA concepts"
echo "  ✓ Alerting best practices (avoid alert fatigue)"
echo "  ✓ Performance tuning (CPU, Memory, Disk, Network)"
echo "  ✓ Monitoring infrastructure as code"

echo -e "\n💡 Production Scenarios:"
echo "  Q1: CPU usage at 100% - How to troubleshoot?"
echo "      A: top/htop → identify process → check logs → kill/restart if needed"
echo "  Q2: Memory leak detection?"
echo "      A: Monitor memory growth over time → heap dump → code review"
echo "  Q3: Disk full at 3 AM - Action?"
echo "      A: Find large files (du -sh), clean logs, set up alerts, auto-cleanup"

echo -e "\n✅ Day 5 completed: Monitoring & Performance fundamentals"
