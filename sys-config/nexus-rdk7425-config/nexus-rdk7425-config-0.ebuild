inherit package-config

DESCRIPTION="Nexus configuration files for rdk7425 board"
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="mips"
IUSE=""

DEPEND=""
RDEPEND=""
PROVIDE="virtual/nexus-config"

src_install() {
   cp "${FILESDIR}"/${PV}/setup.nexus ${T}/setup
      store_config media-libs/nexus-unified ${T}/setup
	  }
