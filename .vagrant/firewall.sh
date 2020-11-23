#!/bin/bash

# Firewall Allow
ufw allow from 192.168.99.0/24
ufw allow from 192.168.0.0/24

ufw allow from 192.168.99.0/24 to any port 6443
ufw allow from 192.168.99.0/24 to any port 2379
ufw allow from 192.168.99.0/24 to any port 2380
ufw allow from 192.168.99.0/24 to any port 68


ufw allow from 192.168.0.0/24 to any port 6443
ufw allow from 192.168.0.0/24 to any port 2379
ufw allow from 192.168.0.0/24 to any port 2380
ufw allow from 192.168.0.0/24 to any port 68

ufw allow from 10.0.2.0/24 to any port 6443
ufw allow from 10.0.2.0/24 to any port 2379
ufw allow from 10.0.2.0/24 to any port 2380
ufw allow from 10.0.2.0/24 to any port 68

ufw enable
ufw reload