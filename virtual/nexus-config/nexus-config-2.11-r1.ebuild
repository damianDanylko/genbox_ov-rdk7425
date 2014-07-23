# Copyright 2006-2014 Wyplay. All Rights Reserved.

EAPI=1

IUSE_WYPLAY_BOARD="rdk7425 bcm97241usff bcm97241usff_b0 bcm97405 bcm97413 bcm97435c betty dc860m dn350m hmb2260 isb6030 isb8k203r isb8k320e isb8kes10 ipv5k1es0 bcm97425sv"
inherit platform-config

DESCRIPTION="virtual to use correct nexus setup"
HOMEPAGE="http://www.wyplay.com"
SRC_URI=""

LICENSE="Wyplay"
SLOT="0"
KEYWORDS="mips"
IUSE=""

DEPEND=""
RDEPEND="wyplay_board_rdk7425? ( sys-config/nexus-rdk7425-config )
wyplay_board_bcm97241usff? ( sys-config/nexus-bcm97241usff-config )
wyplay_board_bcm97241usff_b0? ( sys-config/nexus-bcm97241usff_b0-config )
wyplay_board_bcm97405? ( sys-config/nexus-bcm97405-config )
wyplay_board_bcm97413? ( sys-config/nexus-bcm97413-config )
wyplay_board_bcm97435c? ( sys-config/nexus-bcm97435c-config )
wyplay_board_betty? ( sys-config/nexus-betty-config )
wyplay_board_dc860m? ( sys-config/nexus-bcm97425sv-config )
wyplay_board_dn350m? ( sys-config/nexus-dn350m-config )
wyplay_board_hmb2260? ( sys-config/nexus-bcm97241usff_b0-config )
wyplay_board_ipv5k1es0? ( sys-config/nexus-bcm97241usff_b0-config )
wyplay_board_isb6030? ( sys-config/nexus-isb6030-config )
wyplay_board_isb8k203r? ( sys-config/nexus-bcm97241usff-config )
wyplay_board_isb8k320e? ( sys-config/nexus-bcm97241usff_b0-config )
wyplay_board_isb8kes10? ( sys-config/nexus-isb8kes10-config )
wyplay_board_bcm97425sv? ( sys-config/nexus-bcm97425sv-config )"

