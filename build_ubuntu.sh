#! /bin/bash
# Author: Codemao Junchao Zhang
# Usage: Build the custom ubuntu iso
# structure:
#    prepare_chroot
#    start_chroot
#    custom_iso
#    make_iso
#    make_usb
#

Type=$1;
CONFIG_FILE='./custom_ubuntu_iso.config'
ORIGIN_ISO_FILE='ubuntu-16.04.1-desktop-amd64.iso'
ISO_NAME='ubuntu-16.04-desktop-amd64-custom.iso'
IMAGE_NAME='Codemao-ubuntu-0.1'
PROJECT_PATH='/home/dev/dev/ubuntu/livecdtmp/build-custom-ubuntu'

custom_echo() {
    echo -e "\e[1;31m $1 \e[0m"
}

mount_iso() {
    custom_echo "mounting iso..."
    mkdir mnt
    mkdir extract-cd
    sudo mount ${ORIGIN_ISO_FILE} ${PROJECT_PATH}/mnt
    sudo rsync --exclude=/casper/filesystem.squashfs -a ${PROJECT_PATH}/mnt/ extract-cd
    sudo unsquashfs mnt/casper/filesystem.squashfs
    sudo mv squashfs-root edit
}

prepare_get_into_chroot() {
    custom_echo "geting into chroot..."
    sudo cp /etc/apt/sources.list edit/etc/apt/
    sudo cp /etc/resolv.conf edit/etc/
    sudo mount -o bind /run/ edit/run/
    sudo mount -o bind /dev/ edit/dev/
    sudo cp -r ${PROJECT_PATH}/chroot_scripts ${PROJECT_PATH}/edit/root/
}

get_into_chroot() {
    sudo chroot ${PROJECT_PATH}/edit /bin/bash 
}

customize_in_chroot() {
    custom_echo "customize in chroot..."
    #sudo chroot ${PROJECT_PATH}/edit /root/chroot_scripts/customize_iso.sh
}

prepare() {
    custom_echo "cleaning before make chroot environment..."
    sudo umount ${PROJECT_PATH}/mnt
    sudo rm -rf ${PROJECT_PATH}/${ISO_NAME}
    custom_echo "still execute, don't exit"
    sudo rm -rf mnt
    sudo rm -rf extract-cd
    sudo rm -rf edit
    mount_iso
}

cleanup() {
    custom_echo "cleaning after making iso"
    cleanup_in_chroot
    cleanup_outside
}

cleanup_in_chroot() {
    custom_echo "cleaning up in chroot..."
    sudo chroot ${PROJECT_PATH}/edit /root/chroot_scripts/cleanup.sh
}

cleanup_outside() {
    custom_echo "cleaning up outside..."
    aptitude clean
    sudo umount edit/dev
}

make_iso() {
    custom_echo "making iso..."
    regenerate_manifest
    compress_filesystem
    update_filesystem_size
    caculate_new_md5
    create_iso
}

regenerate_manifest() {
    custom_echo "  regenerating mainfest..."
    sudo chmod +w extract-cd/casper/filesystem.manifest
    sudo chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
    sudo cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
    sudo sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop
    sudo sed -i '/casper/d' extract-cd/casper/filesystem.manifest-desktop
}

compress_filesystem() {
    custom_echo "  compressing filesystem..."
    sudo rm extract-cd/casper/filesystem.squashfs
    sudo mksquashfs edit extract-cd/casper/filesystem.squashfs -b 1048576
}

update_filesystem_size() {
    custom_echo "  updating filesystem size..."
    sudo printf $(du -sx --block-size=1 edit | cut -f1) > extract-cd/casper/filesystem.size
}

caculate_new_md5() {
    custom_echo "  caculating new md5..."
    cd extract-cd
    sudo rm md5sum.txt
    find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt
}

create_iso() {
    custom_echo "  creating iso..."
    sudo mkisofs -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../$ISO_NAME .
}

burn_usb() {
    custom_echo "  burning to usb..."
    #isohybrid ${PROJECT_PATH}/${ISO_NAME}
    lsblk -S |awk 'NR>1 {printf "%s %s %s\n",NR-1,$1,$5}'
    read -p "Select the disk to burn:" DISKNUM
    DISKNUM=$[$DISKNUM+1]
    DISK=$(lsblk -S |awk -v disknum=$DISKNUM 'NR==disknum {print $1}')
    custom_echo "  buring,please wait"
    sudo dd if=${PROJECT_PATH}/${ISO_NAME} of=/dev/$DISK bs=4k
    custom_echo "buring usb complete..."
}

if [ -z "${Type}" ]; then
    before_get_into_chroot
    customize_in_chroot
    cleanup
    make_iso
    burn_usb
fi

if [ "${Type}" = "all" ]; then
    prepare
    prepare_get_into_chroot
    customize_in_chroot
    cleanup
    make_iso
    burn_usb
fi

if [ "$Type" = "chroot" ]; then
    prepare_get_into_chroot
    get_into_chroot
fi

if [ "$Type" = "iso" ]; then
    make_iso
fi

if [ "$Type" = "usb" ]; then
    burn_usb
fi

if [ "$Type" = "clean" ]; then
    clean_before_make_chroot_environment
fi

if [ "$Type" = "prepare" ]; then
    prepare
fi
