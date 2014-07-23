# Copyright 2006-2014 Wyplay. All Rights Reserved.


IUSE="+make-symlinks redist oprofile"
IUSE_WYPLAY_BOARD="rdk7425"

: ${EGIT_GROUP:="damianDanylko"}
:${EGIT_REPO_URI:="https://github.com/damianDanylko/porting_kernel-brcm-3-3-y.git"}
: ${EGIT_BRANCH:="master"}
: ${EGIT_REV:="3fa91ed845a54c5b188272d8cdd38f914e34e534"}

# linux-mod is inherited only for update_depmod function
# so we need to provide pkg_preinst, pkg_postinst, pkg_postrm
# IUSE_WYPLAY_BOARD shall be declared before inheriting platform-config
inherit eutils toolchain-funcs platform-config git package-config linux-mod

EAPI="1"
DESCRIPTION="Broadcom kernel sources"
HOMEPAGE="http://www.broadcom.com"
SRC_URI=""

LICENSE="Broadcom"
SLOT="0"
KEYWORDS="mips"

DEPEND=""
RDEPEND=""
PROVIDE="virtual/linux-sources"

RESTRICT="strip binchecks"
S="${WORKDIR}/${P}"

# set a kernel config option
# usage: kconfig_option [y|n|m] OPTION_NAME (without 'CONFIG_')
# TODO: support string options (like CONFIG_INITRAMFS_SOURCE)
kconfig_option() {
	case $1 in
		y|m)
			if grep "CONFIG_$2=" .config > /dev/null; then
				sed -i -e "s:.*CONFIG_$2.*:CONFIG_$2=$1:g" .config
			elif grep "CONFIG_$2" .config > /dev/null; then
				sed -i -e "s:.*CONFIG_$2.*set:CONFIG_$2=$1:g" .config
			else
				echo "CONFIG_$2=$1" >> .config
			fi
			;;

		n)
			if grep "CONFIG_$2" .config > /dev/null; then
				sed -r -i -e "s:CONFIG_$2=(y|m):# CONFIG_$2 is not set:g" .config
			else
				echo "# CONFIG_$2 is not set" >> .config
			fi
			;;
		esac
	echo $(grep "CONFIG_$2[= ]" .config)
}

# setup the base defconfig to build this target
setup_defconfig() {
	if use wyplay_board_rdk7425; then
		DEFCONFIG=rdk7425
		LOCALVER=rdk7425
	else
		die "Board not supported"
	fi
	load_config rdk7425_defconfig && mv rdk7425_defconfig ${S}/arch/mips/configs/${DEFCONFIG}_defconfig
	make ${DEFCONFIG}_defconfig || die "make defconfig"

	# rewrite CONFIG_LOCALVERSION to include package rev
	sed -i -e "s:.*CONFIG_LOCALVERSION.*:CONFIG_LOCALVERSION=\"-${LOCALVER}\":g" .config
	kconfig_option n LOCALVERSION_AUTO
}

pkg_setup() {
	einfo "nothing to do here, but don't remove this function, as it will break the linux-mod inherit hack up there..."
}

src_unpack() {
	git_src_unpack
}


setup_kconfig() {
	if use android; then
		# standard linux options
		kconfig_option y INET_TUNNEL
		kconfig_option y LEGACY_PTYS
		kconfig_option y MEDIA_SUPPORT
		kconfig_option y FB
		kconfig_option y RTC_CLASS
		kconfig_option y STAGING

		# android-specific stuff
		kconfig_option y ANDROID
		kconfig_option y ANDROID_BINDER_IPC
		kconfig_option y ANDROID_LOGGER
		kconfig_option y ANDROID_LOW_MEMORY_KILLER
		kconfig_option y ANDROID_PARANOID_NETWORK
		kconfig_option y ANDROID_PMEM
		kconfig_option y ANDROID_RAM_CONSOLE
		kconfig_option y ANDROID_RAM_CONSOLE_ENABLE_VERBOSE
		kconfig_option y ANDROID_TIMED_OUTPUT
		kconfig_option y ASHMEM

		# bluetooth
		kconfig_option y BT
		kconfig_option y BT_HCIBTUSB
		kconfig_option y BT_HIDP
		kconfig_option y BT_L2CAP

		# pm
		kconfig_option y MACH_NO_WESTBRIDGE
		kconfig_option y DEVMEM
		kconfig_option y EARLYSUSPEND
		kconfig_option y FB_EARLYSUSPEND
		kconfig_option y HAS_EARLYSUSPEND
		kconfig_option y HAS_WAKELOCK

		# input
		kconfig_option y HID_MAGICMOUSE

		# ipv6
		kconfig_option y IPV6
		kconfig_option y INET6_XFRM_MODE_BEET
		kconfig_option y INET6_XFRM_MODE_TRANSPORT
		kconfig_option y INET6_XFRM_MODE_TUNNEL
		kconfig_option y IP6_NF_IPTABLES
		kconfig_option y IPV6_NDISC_NODETYPE
		kconfig_option y IPV6_SIT
		kconfig_option y IPV6_SIT_6RD

		# nf
		kconfig_option y NETFILTER
		kconfig_option y NETFILTER_ADVANCED
		kconfig_option y NETFILTER_TPROXY
		kconfig_option y NETFILTER_XTABLES
		kconfig_option y BRIDGE_NETFILTER
		kconfig_option y IP_NF_IPTABLES
		kconfig_option y IP_NF_MANGLE
		kconfig_option y NF_CONNTRACK
		kconfig_option y NF_CONNTRACK_IPV4
		kconfig_option y NF_CONNTRACK_PROC_COMPAT
		kconfig_option y NF_DEFRAG_IPV4
		kconfig_option y NF_DEFRAG_IPV6

		kconfig_option y NETFILTER_XT_MATCH_QTAGUID
		kconfig_option y NETFILTER_XT_MATCH_QUOTA2
		kconfig_option y NETFILTER_XT_MATCH_SOCKET
		kconfig_option y NETFILTER_XT_MATCH_STATE

		kconfig_option y NET_ACTIVITY_STATS


		# ipvs
		kconfig_option y IP_VS
	fi

	if use oprofile; then
		kconfig_option y PROFILING
		kconfig_option y OPROFILE
	fi

	kconfig_option y ROMBLOCK
}

src_compile() {
	# disable LDFLAGS
	unset LDFLAGS

	MAKEOPTS="${MAKEOPTS} ARCH=`tc-arch-kernel` CROSS_COMPILE=${CHOST}-"

	ebegin "Running make mrproper"
	make ${MAKEOPTS} mrproper || die "make mrproper"
	eend $?

	setup_defconfig
	setup_kconfig

	ebegin "Running make oldconfig"
	echo 'n' | make ${MAKEOPTS} oldconfig || die "make oldconfig"
	eend $?

	ebegin "Running make"
	make ${MAKEOPTS} || die "make"
	eend $?

	ebegin "Running make modules"
	make ${MAKEOPTS} modules || die "make modules"
	eend $?
}

src_install() {
	# disable LDFLAGS
	unset LDFLAGS

	MAKEOPTS="${MAKEOPTS} ARCH=`tc-arch-kernel` CROSS_COMPILE=${CHOST}-"

	ebegin "Running make modules_install"
	INSTALL_MOD_PATH=${D} make ${MAKEOPTS} modules_install || die "make modules_install"
	eend $?

	if use redist; then
		ebegin "Running make modules_install"
		INSTALL_MOD_PATH=${D}/redist make ${MAKEOPTS} modules_install || die "make modules_install"
		eend $?
	fi

	dodir /usr/src
	cp -a "${S}" "${D}"/usr/src
	if use make-symlinks; then
		cd "${D}"/usr/src
		ln -s "${P}" linux
	fi
	dodir /boot
	insinto /boot
	doins "${S}"/vmlinux
}


pkg_preinst() {
	einfo "Only to avoid linux-mod pkg_preinst call"
}

pkg_postinst() {
	# call function provided by linux-mod eclass
	update_depmod

	cd "${ROOT}"/usr/src/linux
	make ARCH=`tc-arch-kernel` CROSS_COMPILE="${CHOST}-" prepare
}

pkg_postrm() {
	einfo "Only to avoid linux-mod pkg_postrm call"
}

