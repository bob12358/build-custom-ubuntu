#! /bin/bash

mount_iso() {
    mkdir mnt
    mkdir extract-cd
    sudo mount ${ISO_NAME} ${PROJECT_PATH}/mnt
}

unzip_squashfs() {
    sudo rsync --exclude=/casper/filesystem.squashfs -a ${PROJECT_PATH}/mnt/ extract-cd
    sudo unsquashfs mnt/casper/filesystem.squashfs
    sudo mv squashfs-root edit
}

start_chroot() {
    sudo cp start_chroot.sh ${PROJECT_PATH}/edit/root/
    sudo cp end_chroot.sh ${PROJECT_PATH}/edit/root/
    sudo chroot ${PROJECT_PATH}/edit /bin/bash
}

copy_script_run_in_chroot() {

    
    sudo cp -r runscripts ${PROJECT_PATH}/edit
}


echo "mount iso start..."
mount_iso
echo "mount iso end..."


echo "unzip squashfs start..."
unzip_squashfs
echo "unzip squashfs end..."
