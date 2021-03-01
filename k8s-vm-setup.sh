#!/bin/bash

# Enable overlay and br_netfilter
cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF

# Disable swap
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
swapoff -a

# Apply sysctl params without reboot
sysctl --system

# Update system dependencies and install containerd.
export DEBIAN_FRONTEND=noninteractive
apt-get update && \
 apt-get install -y \
 containerd \
 apt-transport-https \
 ca-certificates \
 curl \
 software-properties-common

# Configure containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# Restart containerd
systemctl restart containerd

# Install kubeadm, kubectl, kubelet packages
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Set cgroup driver to containerd
mkdir -p /var/lib/kubelet
echo "apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: containerd" | tee /var/lib/kubelet/config.yaml


# sudo kubeadm init --pod-network-cidr=192.168.1.0/24 \
#   --upload-certs \
#   --control-plane-endpoint=192.168.1.11:6443 \
#   --apiserver-advertise-address=192.168.1.11 