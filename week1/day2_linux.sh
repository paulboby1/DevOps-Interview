#!/bin/bash
# Week 1 Day 2 – Linux Users, Permissions & Process Management
# Run: ./week1/day2_linux.sh

clear
echo "=== DevOps L1 – Week 1 Day 2 – $(date '+%Y-%m-%d %H:%M') ==="
echo "System: $(hostname) | User: $(whoami) | Groups: $(groups)"
echo "----------------------------------------------------------"

echo "1. User & Group Management"
echo "Total users: $(wc -l < /etc/passwd)"
echo "Recent users (last 5):"
tail -5 /etc/passwd | awk -F: '{print "  " $1 " (UID:" $3 ", Home:" $6 ")"}'

echo -e "\n2. Current User Permissions"
echo "Home directory permissions:"
ls -ld $HOME
echo "Sudo access check:"
sudo -l 2>/dev/null | head -3 || echo "  No sudo privileges or cannot check"

echo -e "\n3. File Permissions Demo"
TEST_FILE="/tmp/devops_test.txt"
echo "Testing file permissions..." > $TEST_FILE
chmod 644 $TEST_FILE
echo "File: $TEST_FILE ($(ls -l $TEST_FILE | awk '{print $1, $3, $4}'))"
rm -f $TEST_FILE

echo -e "\n4. Running Processes Count"
echo "Total processes: $(ps aux | wc -l)"
echo "Root processes: $(ps aux | grep ^root | wc -l)"
echo "User processes: $(ps aux | grep ^$(whoami) | wc -l)"

echo -e "\n5. Process Tree (init/systemd)"
pstree -p $$ | head -3 || echo "pstree not available"

echo -e "\n6. System Logs Check"
echo "Recent auth attempts (last 5):"
if [ -r /var/log/auth.log ]; then
    sudo tail -5 /var/log/auth.log 2>/dev/null || echo "  Cannot read auth logs"
elif [ -r /var/log/secure ]; then
    sudo tail -5 /var/log/secure 2>/dev/null || echo "  Cannot read secure logs"
else
    echo "  No auth logs accessible"
fi

echo -e "\n7. File Search Examples"
echo "Find SUID files in /usr/bin (security audit):"
find /usr/bin -type f -perm -4000 2>/dev/null | head -5
echo "  ... (showing first 5 only)"

echo -e "\n8. Interview one-liners:"
echo "# Find files modified in last 24h: find /path -type f -mtime -1"
echo "# Change ownership recursively: chown -R user:group /path"
echo "# Kill process by name: pkill -9 processname"
echo "# Check failed login attempts: lastb | head"

echo -e "\n9. Practice Commands (Info Only):"
echo "  useradd/usermod/userdel - User management"
echo "  chmod/chown/chgrp - Permission management"
echo "  ps/top/htop/pgrep - Process monitoring"
echo "  kill/pkill/killall - Process termination"
echo "  journalctl - Systemd logs (journalctl -xe)"

echo -e "\nDay 2 completed successfully. Key topics: Users, Permissions, Processes, Logs."
