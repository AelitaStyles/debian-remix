#!/bin/bash
# Copyright (C) 2022, Aelita Styles
# License available at: https://github.com/AelitaStyles/debian-remix/blob/main/LICENSE.md
echo ">> Setting up mountpoints... "
mount none -t proc /proc > /dev/null
if [ $? -ne 0 ]; then
	echo ">> failed."
	exit 1
fi
mount none -t sysfs /sys > /dev/null
if [ $? -ne 0 ]; then
	echo ">> failed."
	exit 1
fi
mount none -t devpts /dev/pts > /dev/null
if [ $? -ne 0 ]; then
	echo ">> failed."
	exit 1
else
	echo ">> ok."
fi

echo ">> Setting up environment... "
export HOME="/root"
export LC_ALL="C"
echo ">> ok."

echo ">> Installing DBus and dependencies... "
apt-get -y install dialog dbus
if [ $? -ne 0 ]; then
	echo ">> failed."
	exit 1
else
	echo ">> ok."
fi

echo ">> Setting up DBus... "
dbus-uuidgen > /var/lib/dbus/machine-id
if [ $? -ne 0 ]; then
	echo ">> failed."
	exit 1
else
	echo ">> ok."
fi

echo ">> Setting up LiveCD... "
apt-get -y install "linux-image-$1" live-boot
if [ $? -ne 0 ]; then
	echo ">> failed."
	exit 1
else
	echo ">> ok."
fi

echo ">> Running setup.sh... "
/setup/setup.sh
if [ $? -ne 0 ]; then
	echo ">> failed."
	exit 1
else
	echo ">> ok."
fi

echo ">> Cleaning up apt-get caches... "
apt-get -y clean
if [ $? -ne 0 ]; then
	echo ">> failed."
	exit 1
else
	echo ">> ok."
fi

echo ">> Removing DBus Setup... "
rm -v /var/lib/dbus/machine-id
if [ $? -ne 0 ]; then
	echo ">> failed."
	exit 1
else
	echo ">> ok."
fi

echo -n ">> Removing temporary files... "
rm -rvf /tmp/*
if [ $? -ne 0 ]; then
	echo ">> failed."
	exit 1
else
	echo ">> ok."
fi

echo -n ">> Unmounting mountpoints... "
umount /proc /sys /dev/pts
if [ $? -ne 0 ]; then
	echo ">> failed."
	exit 1
else
	echo ">> ok."
fi

exit 0