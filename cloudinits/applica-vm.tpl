#cloud-config

write_files:
- content: |
    blacklist {
        devnode "^(ram|raw|loop|fd|md|dm-|sr|scd|st|sda|sdb|sdc)[0-9]*"
    }
  path: /etc/multipath.conf

write_files:
- content: |
    network:
      ethernets:
        ens192:
          addresses: [${vm_ip}/24]
          gateway4: ${vm_gateway_ip}
          nameservers:
            addresses: [77.88.8.8, 1.1.1.1]
  version: 2
  path: /etc/netplan/50-cloud-init.yaml

runcmd:
- netplan apply
- echo 'blacklist floppy' | tee /etc/modprobe.d/blacklist-floppy.conf
- rmmod floppy
- update-initramfs -u
- apt update
- apt -y install pv mc vim-nox unzip zstd htop tmux apt-transport-https
- apt -y autoremove
- apt clean
- usermod --password '$6$siWdFkT28oi$3K6HaHNFIiqvhI5zI854sbwZkDyB9x8450z7joCzVIpLRtYeoNMSJubs0EVMKPiUD5MAYvE/BhR.YDPEpGaeH/' root # прописывает для root пароль 123. Такой хэш создаётся командой mkpasswd -m SHA-512
- sed -i 's/disable_root: true/disable_root: false/g' /etc/cloud/cloud.cfg
- sed -i 's/preserve_hostname: false/preserve_hostname: true/g' /etc/cloud/cloud.cfg

users:
  - name: user1
    gecos: User 1
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: admin, sudo
    ssh_import_id: None
    lock_passwd: true
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpPmKG37/Kvlncs+oYm+Qyen67NDhnJq1ehIp6VLzRL user1@example

  - name: user2
    gecos: User 2
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: admin,sudo
    ssh_import_id: None
    lock_passwd: false
    passwd: $5$FvcvS404E3jj7F$1BcprGKtUmAxavzbJnG9Q3z5zRDBtg1mqc.tFy1tgIC
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/Xs5xbYDxkzp59ZdPmkG/EA8zPOv0tdtyPASJOtenG user2@example
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtrGol8atkovwV9++Sj5OVpLlx4+iW2BVhdjX3Ujme5L+f6rpEN7UJQNOQc8Z0bhTXcIJJIRdZP89dj+9sVQ+SYgJf2UT7j6qbt5t5Owk54YaAF6PZIcGe5oDnOehqVBNMELYKveOk02hIRO7uqdkH+Yv4Pxd5ZFgZSaGMxO1tWoRTjFc2qMbF4LtCWKiniTesUdHTQ271cv5aJPnzFbZ1ywOV5IWaOf9CvCYbXcCuKutLrobv5ZtY1Vc3yWhPdJFQK5fwOb9RvZX1mEoEdu1KEM/5zB1GczgoIUpSdSe/XBqvC08mYhpBgTKlXbQ6TyPVe76ohgSH7PhAa8ly9rhD user2@example