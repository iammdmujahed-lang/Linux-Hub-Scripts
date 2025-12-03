#!/bin/bash
echo "==== CPU & MEMORY ===="
echo
echo "Load Average:"
uptime
echo
echo "Top 5 CPU consuming processes:"
ps aux --sort=-%cpu | head -n 6
echo
echo "Top 5 Memory consuming processes:"
ps aux --sort=-%mem | head -n 6
echo
echo "Memory usage:"
free -h
