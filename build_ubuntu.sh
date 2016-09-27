#! /bin/bash
# Author: Codemao Junchao
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
ISO_NAME='ubuntu-16.04-desktop-amd64-custom.iso'
IMAGE_NAME='Codemao-ubuntu-0.1'
PROJECT_PATH='/home/dev/dev/ubuntu/livecdtmp'
SCRIPT_PATH=''

# Load all of the script files
for script_file (${SCRIPT_PATH}); do
  [ -fx "${custom_config_file}" ]
  source $script_file
done

mount_iso() {
    echo "mounting iso..."
    mkdir mnt
    mkdir extract-cd
    sudo mount ${ISO_NAME} ${PROJECT_PATH}/mnt
    sudo rsync --exclude=/casper/filesystem.squashfs -a ${PROJECT_PATH}/mnt/ extract-cd
    sudo unsquashfs mnt/casper/filesystem.squashfs
    sudo mv squashfs-root edit
}

get_into_chroot() {
    echo "starting chroot..."
    sudo cp start_chroot.sh ${PROJECT_PATH}/edit/root/
    sudo cp end_chroot.sh ${PROJECT_PATH}/edit/root/
    sudo chroot ${PROJECT_PATH}/edit /bin/bash 
}

customize_in_chroot() {
    echo "customize in chroot..."
    sudo chroot ${PROJECT_PATH}/edit /root/chroot_scripts/customize_iso.sh
}

prepare() {
    echo "cleaning before make chroot environment..."
    sudo rm -rf mnt
    sudo rm -rf extract-cd
    sudo rm -rf edit
}

cleanup() {
   echo "cleaning before make iso"
   cleanup_in_chroot
   cleanup_outside
}

cleanup_in_chroot() {
   echo "cleaning up in chroot..."
   sudo chroot ${PROJECT_PATH}/edit /root/chroot_scripts/cleanup.sh
}

cleanup_outside() {
   echo "cleaning up outside..."
   sudo umount edit/dev
}

make_iso() {
    echo "making iso..."
    regenerate_manifest
    compress_filesystem
    update_filesystem_size
    caculate_new_md5
}

regenerate_manifest() {
    echo "  regenerating mainfest..."
    chmod +w extract-cd/casper/filesystem.manifest
    sudo su
    chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
    exit
    sudo cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
    sudo sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop
    sudo sed -i '/casper/d' extract-cd/casper/filesystem.manifest-desktop
}

compress_filesystem() {
    echo "  compressing filesystem..."
    sudo rm extract-cd/casper/filesystem.squashfs
    sudo mksquashfs edit extract-cd/casper/filesystem.squashfs -b 1048576
}

update_filesystem_size() {
    echo "  updating filesystem size..."
    sudo su
    printf $(du -sx --block-size=1 edit | cut -f1) > extract-cd/casper/filesystem.size
    exit
}

caculate_new_md5() {
    echo "  caculating new md5..."
    cd extract-cd
    sudo rm md5sum.txt
    find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt
}

create_iso() {
    echo "  creating iso..."
    sudo mkisofs -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../$ISO_NAME .
}

make_usb() {

}

if [-z "$Type"]; then
    prepare
    start_chroot
    customize_in_chroot
    cleanup
    make_iso
    make_usb
fi

if ["$Type" = "chroot"]; then
    start_chroot
fi

if ["$Type" = "iso"]; then
    make_iso
fi

if ["$Type" = "usb"]; then
    make_usb
fi

if ["$Type" = "clean"]; then
    clean_before_make_chroot_environment
fi
