#! /bin/bash

echo "preparing chroot... "
sudo mount -o bind /run/ edit/run
sudo cp /etc/hosts edit/etc/
sudo mount --bind /dev/ edit/dev
sudo -S ${PROJECT_PATH}/chroot edit
