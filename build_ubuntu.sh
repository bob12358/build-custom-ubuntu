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

start_chroot() {
    echo "starting chroot..."
    sudo cp start_chroot.sh ${PROJECT_PATH}/edit/root/
    sudo cp end_chroot.sh ${PROJECT_PATH}/edit/root/
    sudo chroot ${PROJECT_PATH}/edit /bin/bash
}


clean_before_make_chroot_environment() {
    echo "cleaning before make chroot environment..."
    sudo rm -rf mnt
    sudo rm -rf extract-cd
    sudo rm -rf edit
}
