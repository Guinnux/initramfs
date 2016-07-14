#!/bin/sh

if [ $# -lt 1 ]; then
	echo "Not Enough arguments"
	exit 1
fi

ARCH=$1
case $ARCH in
	arm)
	ARCH_PREFIX=arm-gnx5-linux-gnueabi
	IMG_DIR=$PWD/image/$ARCH
	;;
	aarch64)
	ARCH_PREFIX=aarch64-gnx5-linux-gnueabi
	IMG_DIR=$PWD/image/$ARCH
	;;
	*)
	echo "Unsupported architecture $ARCH"
	exit 1
esac

echo "Using arch '$ARCH' .."
echo "Using tuple '$ARCH_PREFIX' .."
echo "Using output directory '$IMG_DIR' .."

echo "Cleaning old images .."
if [ -e $IMG_DIR ]; then
	rm -fR $IMG_DIR
fi

echo "Preparing image directory .."
mkdir -p $IMG_DIR/var/lib/pacman

echo "Updating repository databases .."
$ARCH_PREFIX-pacman -r $IMG_DIR -Sy 

echo "Installing skeleton filesystem .."
$ARCH_PREFIX-pacman -r $IMG_DIR -S --noconfirm filesystem

rm -fR $IMG_DIR/etc/profile
$ARCH_PREFIX-pacman -r $IMG_DIR -S --noconfirm glibc
$ARCH_PREFIX-pacman -r $IMG_DIR -S --noconfirm busybox-rescue
$ARCH_PREFIX-pacman -r $IMG_DIR -S --noconfirm e2fsprogs-rescue

echo "Putting filesystem on a diet .."
rm -fR $IMG_DIR/usr/include
rm -fR $IMG_DIR/usr/share/iana-etc
rm -fR $IMG_DIR/usr/share/info
rm -fR $IMG_DIR/usr/share/licenses
rm -fR $IMG_DIR/usr/share/man
rm -fR $IMG_DIR/usr/share/misc
rm -fR $IMG_DIR/usr/share/locale
rm -fR $IMG_DIR/usr/share/i18n
rm -fR $IMG_DIR/usr/share/zoneinfo
rm -fR $IMG_DIR/usr/lib/*.a
rm -fR $IMG_DIR/usr/lib/*.la
rm -fR $IMG_DIR/usr/lib/audit
rm -fR $IMG_DIR/usr/lib/gconv
rm -fR $IMG_DIR/usr/lib/getconf
rm -fR $IMG_DIR/var/lib/pacman

$ARCH_PREFIX-strip $IMG_DIR/usr/lib/*.so
$ARCH_PREFIX-strip $IMG_DIR/usr/bin/*

install -D -m755 ./init  $IMG_DIR/init
install -d -m644 $IMG_DIR/mnt/rescRO
install -d -m644 $IMG_DIR/mnt/rescRW
install -d -m644 $IMG_DIR/mnt/rescue
install -d -m644 $IMG_DIR/mnt/gnx

tar -cvzf initramfs-$ARCH.tar.gz image/$ARCH





