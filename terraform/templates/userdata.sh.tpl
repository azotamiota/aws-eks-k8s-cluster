#!/bin/bash -e
%{ if "${additional_disk_size}" != 0 }
# mount additional disks
EBS_DEVICE=( $(lsblk | grep -e disk | awk '{sub("G","",$4)} {if ($4+0 == ${additional_disk_size}) print $1}') )
for i in "$${!EBS_DEVICE[@]}"; do sudo mkfs -t xfs /dev/"$${EBS_DEVICE[$i]}"; done
sudo mkdir -p /var/lib/kubelet/pods/
sudo mkdir -p /var/lib/containerd/
PATHS=("/var/lib/kubelet/pods/" "/var/lib/containerd/")
sudo cp /etc/fstab /etc/fstab.orig
for i in "$${!EBS_DEVICE[@]}"; do sudo mount /dev/"$${EBS_DEVICE[$i]}" "$${PATHS[$i]}"; done
for i in "$${!EBS_DEVICE[@]}"; do sudo echo -e "UUID=$(blkid | grep $${EBS_DEVICE[$i]} | awk -F '\"' '{print $2}')     $${PATHS[$i]}           xfs    defaults,nofail  0   2" >> /etc/fstab; done
sudo mount -a
%{ endif }
# Allow user supplied pre userdata code
${pre_userdata}

sed -i '/^KUBELET_EXTRA_ARGS=/a KUBELET_EXTRA_ARGS+=" ${kubelet_extra_args}"' /etc/eks/bootstrap.sh
