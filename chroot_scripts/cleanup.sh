#! /bin/bash
aptitude clean
rm -rf /tmp/* ~/.bash_history
#rm -rf /etc/hosts
rm /etc/resolv.conf
sudo ln -s /run/resolvconf/resolv.conf /etc/resolv.conf
sudo resolvconf -u
rm /var/lib/dbus/machine-id
#rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

umount -lf /proc
umount -lf /sys
umount -lf /dev/pts
