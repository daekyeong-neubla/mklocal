#!/bin/bash

readonly disks=(/dev/nvme*n1)
readonly vg=vg_local
readonly lv=lv_local
readonly mount_point=/local

sudo umount --force /local || true

for disk in "${disks[@]}"; do sudo pvcreate -ff -y "$disk"; done

sudo vgremove -f "$vg" || true
sudo vgcreate -ff -y "$vg" "${disks[@]}"

sudo lvcreate -l 100%FREE -n "$lv" "$vg"

sudo mkfs.ext4 -F "/dev/$vg/$lv"

sudo mkdir -p "$mount_point"
sudo mount "/dev/$vg/$lv" "$mount_point"

sudo chown -R root:developers "$mount_point"
sudo chmod 2775 "$mount_point"


IFS=$'\n' users=($(getent passwd | grep /home | cut -d':' -f1))
IFS=$' \r\n'
for user in "${users[@]}"; do
  sudo mkdir -p "$mount_point/user/$user"
  sudo chown "$user:$user" "$mount_point/user/$user"
  sudo chmod 0700 "$mount_point/user/$user"
done
