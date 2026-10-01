#!/bin/bash

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -C POSTROUTING -o eth5 -j MASQUERADE 2>/dev/null || \
  iptables -t nat -A POSTROUTING -o eth5 -j MASQUERADE
