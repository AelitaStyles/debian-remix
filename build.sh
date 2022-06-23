#!/bin/bash
# Copyright (C) 2022, Aelita Styles
# License available at: https://github.com/AelitaStyles/debian-remix/blob/main/LICENSE.md
source ./config.sh

echo "> Installing Prerequisites... "
sudo apt-get -y install debootstrap squashfs-tools grub-pc-bin grub-efi-amd64-bin grub-efi-ia32-bin xorriso mtools
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi

echo "> Removing Old Build... "
rm -vrf ./build
echo "> ok."

echo "> Creating build directory... "
mkdir -vp ./build/root 
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi

echo "> Installing Debian... "
debootstrap --arch="$TARGET_ARCH" "$BASE_DIST" ./build/root
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi

echo "> Copying chroot.sh and the setup directory... "
cp -v ./utils/chroot.sh ./build/root/chroot.sh
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
chroot ./build/root /chroot.sh "$TARGET_ARCH"
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi

echo "> Removing setup files..."
rm -vf ./build/root/chroot.sh
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
fi
rm -rvf ./build/root/setup
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi

echo "> Creating LiveCD directories..."
mkdir -vp ./build/cd/boot/grub
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
fi
mkdir -vp ./build/cd/live
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi

echo "> Copying kernel, initrd and grub.cfg... "
cp -v ./build/root/boot/vmlinuz-* ./build/cd/live/vmlinuz
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
fi
cp -v ./build/root/boot/initrd.img-* ./build/cd/live/initrd
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
fi
cp -v ./grub.cfg ./build/cd/boot/grub/grub.cfg
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi

echo "> Squashing filesystem..."
mksquashfs ./build/root ./build/cd/live/filesystem.squashfs -comp xz -e boot
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi

echo "> Building ISO..."
grub-mkrescue -o ./build/build.iso ./build/cd
if [ $? -ne 0 ]; then
	echo "> failed."
	exit 1
else
	echo "> ok."
fi