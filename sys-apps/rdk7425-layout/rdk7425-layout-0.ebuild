# Copyright 2006-2014 Wyplay. All Rights Reserved.

inherit makedevs redist git

DESCRIPTION="Boardlayout for Betty board"
HOMEPAGE="http://www.wyplay.com"

RESTRICT="nomirror binchecks"
LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="mips"
IUSE="redist"

PROVIDE="virtual/boardlayout"

: ${EGIT_GROUP:="damianDanylko"}
: ${EGIT_REPO_URI:="https://github.com/damianDanylko/porting_rdk7425-layout.git"}
: ${EGIT_BRANCH:="master"}
# tag 0.2
: ${EGIT_REVISION:="24eb5d6e7e3f2f15d2ec61800f75610218c10809"}

# Remember that we need to define RDEPEND, because it defaults to DEPEND
# udev is not mandatory to use this layout
# RDEPEND="sys-fs/udev"
RDEPEND=""
DEPEND="sys-apps/makedevbr"

RELNAME="Betty"

src_install() {
	einfo "Creating directories..."
	keepdir.redist /bin /etc /root /etc/init.d /etc/modprobe.d /home /lib /sbin /usr /var /mnt /sys
	keepdir.redist /var/log /proc /dev/pts /dev/shm
	keepdir.redist /tmp /media /wymedia /etc/params /etc/firstboot

	# if ROOT=/ and we make /proc, we will get errors when portage tries
	# to create /proc/.keep, so we remove it if we need to
	[ "${ROOT}" = "/" ] && rm -rf ${D}/proc
	[ "${ROOT}" = "" ] && rm -rf ${D}/proc

	######################################## ETC
	einfo "Installing /etc files..."
	dosym.redist /proc/mounts /etc/mtab
	dosym.redist ../tmp/resolv.conf /etc/resolv.conf

	######################################## DEV
	einfo "Creating devices..."
	createdevs ${S}/device_table.txt
	use redist && createredistdevs ${S}/device_table.txt

	dosym.redist /proc/self/fd/2 /dev/stderr
	dosym.redist /proc/self/fd/0 /dev/stdin
	dosym.redist /proc/self/fd/1 /dev/stdout

	######################################## UDEV
	einfo "Installing persistent devices into /lib/udev/devices ..."
	udev.persistent ${S}/udev-persistent.txt

	# FIXME generate locales intead of copying them
	ebegin "Installing locales"
	dodir.redist /usr/lib/locale
	cp -Rdf ${S}/locale/* ${D}/usr/lib/locale
	use redist && cp -Rdf ${S}/locale/* ${D}/redist/usr/lib/locale
	eend $?
}
