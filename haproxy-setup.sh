#!/bin/bash

# Update system dependencies and install haproxy.
export DEBIAN_FRONTEND=noninteractive
apt-get update && \
    apt-get -y install haproxy

cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg 
frontend k8s-ha-proxy
    bind *:6443
    mode tcp
    option tcplog
    tcp-request inspect-delay 5s
    default_backend k8s-master-nodes

backend k8s-master-nodes
    balance roundrobin
    mode tcp
    option tcplog
    option tcp-check
    default-server inter 10s downinter 5s rise 2 fall 3 slowstart 30s maxconn 50 maxqueue 100
    server master-1 192.168.10.11:6443 check rise 2 fall 3
    server master-2 192.168.10.12:6443 check rise 2 fall 3
EOF

systemctl restart haproxy