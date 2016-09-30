#! /bin/bash
CHROOT_SCRIPTS_PATH='/root/chroot_scripts'
DEB_PATH='$CHROOT_SCRIPTS_PATH/deb'

# Add apt repository
sudo add-apt-repository ppa:fcitx-team/nightly
sudo add-apt-repository ppa:ricotz/docky
sudo apt-get update

sudo apt-get -y install aptitude
sudo apt-get -y install git
# install docky
sudo apt-get -y install docky --allow-unauthenticated

# install fcitx
sudo apt-get -y remove ibus
sudo apt-get -y remove scim
sudo apt-get autoremove
sudo apt-get -y install fcitx --allow-unauthenticated
sudo im-switch -s fcitx -z default

# delete amazon
sudo apt-get -y purge unity-webapps-common
# delete firefox
sudo apt-get -y remove firefox

# install MC
#sudo apt-get install openjdk-8-jdk
cp -r $CHROOT_SCRIPTS_PATH/mc /opt/

# install theme
rm -rf /usr/share/themes/Ambiance/
cp -r $CHROOT_SCRIPTS_PATH/OSXtheme/Ambiance /usr/share/themes/

# install icon theme
#rm -rf /usr/share/icons/ubuntu-mono-dark/
#mv $CHROOT_SCRIPTS_PATH/OSXtheme/icons /usr/share/icons/ubuntu-mono-dark/

# Change background
#cp -r $CHROOT_SCRIPTS_PATH/backgrounds/* /usr/share/backgrounds/
#cp -r $CHROOT_SCRIPTS_PATH/com.canonical.unity-greeter.gschema.xml /usr/share/glib-2.0/schemas/
#cp -r $CHROOT_SCRIPTS_PATH/ubuntu-wallpapers.xml /usr/share/glib-2.0/schemas/ /usr/share/gnome-background-properties/

# Change GTK-Theme
# Change Icon-Theme

# Hide launcher
#cp -r $CHROOT_SCRIPTS_PATH/org.compiz.unityshell.gschema.xml /usr/share/glib-2.0/schemas/

#glib-compile-schemas /usr/share/glib-2.0/schemas

# Install zh-hans language support
sudo apt-get -y install `check-language-support -l zh-hans`
sudo cp $CHROOT_SCRIPTS_PATH/locale /etc/default/locale

for deb in $CHROOT_SCRIPTS_PATH/deb/*.deb; do
    sudo dpkg -i $deb
done

# Install sougou skin
mkdir -p /usr/share/sogou-qimpanel/
sudo cp -r $CHROOT_SCRIPTS_PATH/sougou/* /usr/share/sogou-qimpanel/skin

sudo cp -r $CHROOT_SCRIPTS_PATH/*release /etc/

#sudo apt-get install -f install
