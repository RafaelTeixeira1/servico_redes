#!/bin/bash
sysctl -w net.ipv4.ip_forward=1
iptables-restore < /etc/iptables.rules
exec "$@"

