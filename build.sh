#!/bin/bash
# Copyright (C) 2022, Aelita Styles
# License available at: https://github.com/AelitaStyles/debian-remix/blob/main/LICENSE.md
source ./config.sh

echo "> Installing Prerequisites... "
sudo apt-get -y install debootstrap squashfs-tools xorriso
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi

echo "> Removing Old Build... "
rm -vrf ./build > /dev/null
echo "> ok."

echo "> Installing Debian... "
debootstrap --arch="$TARGET_ARCH" "$BASE_DIST" ./build/root
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi

echo "> Copying chroot.sh and the setup directory... "
cp -v ./utils/chroot.sh ./build/root/chroot.sh "$TARGET_ARCH"
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
fi
cp -vR ./setup ./build/root > /dev/null
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi

echo "> Chroot into LiveCD... "
chroot ./build/root /chroot.sh
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi

echo "> Creating LiveCD and ISOLinux directories..."
mkdir -vp ./build/binary/live
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
fi
mkdir -vp ./build/binary/isolinux
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi

echo "> Copying kernel and initrd... "
cp -v ./build/root/boot/vmlinuz-* ./build/binary/live/vmlinuz
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
fi
cp -v ./build/root/boot/initrd.img-* ./build/binary/live/initrd
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi

echo "> Squashing filesystem..."
mksquashfs ./build/root ./build/binary/live/filesystem.squashfs -comp xz -e boot
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi

echo "> Copying ISOLinux files..."
cp -v /usr/lib/syslinux/isolinux.bin ./build/binary/isoliinux/.
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
fi
cp -v /usr/lib/syslinux/menu.c32 ./build/binary/isolinux/.
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
fi
cp -v ./isolinux.cfg ./build/binary/isolinux/.
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi

echo "> Building ISO..."
xorriso -as mkisofs -r -J -joliet-long -l -cache-inodes -isohybrid-mbr /usr/lib/syslinux/isohdpfx.bin -partition_offset 16 -A "$CD_LABEL" -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ./build/build.iso ./build/binary
