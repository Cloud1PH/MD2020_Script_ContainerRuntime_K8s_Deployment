#!/bin/bash
 
#Add repo
add-apt-repository -y ppa:projectatomic/ppa
apt update
 
#Install cri-o 1.15
apt-get install -y cri-o-1.15
ln -s /usr/bin/conmon /usr/libexec/crio/conmon
systemctl start crio
systemctl enable crio
crio -v
 
#install crictl 1.17.0
VERSION="v1.17.0"
curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-${VERSION}-linux-amd64.tar.gz --output crictl-${VERSION}-linux-amd64.tar.gz
tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz
 
#Configure ipv4-forward
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system
modprobe br_netfilter
echo '1' > /proc/sys/net/ipv4/ip_forward
 
#Change cgroup manager from systemd to cgroupfs to avoid issue https://github.com/cri-o/cri-o/issues/896 and add docker.io as default repo
#Download crio.conf from our phdsaasdevops git repo
curl -LO https://raw.githubusercontent.com/phdsaasdevops/MB2020_Script_ContainerRuntime_K8s_Deployment/master/CRI-O/1.15/crio.conf
mv crio.conf /etc/crio/crio.conf
systemctl stop crio
systemctl start crio
 
 
 
#install kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubeadm kubelet kubernetes-cni
systemctl enable kubelet
#https://github.com/kidlj/kube/blob/master/README.md
swapoff -a
echo 'Enter kubeadm join command'
