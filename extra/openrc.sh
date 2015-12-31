#!/bin/sh
#
# Copyright (c) 2015 Angelescu Ovidiu
#
# See COPYING for licence terms.
#
#
# $Id: openrc.sh,v 1.2 2015/30/12 14.07:19 angelescuo Exp $

set -e -u

if [ -z "${LOGFILE:-}" ]; then
	echo "This script can't run standalone."
	echo "Please use launch.sh to execute it."
	exit 1
fi

cd $BASEDIR
git clone https://github.com/OpenRC/openrc $BASEDIR/openrc

cat > ${BASEDIR}/config.sh << 'EOF'
#!/bin/sh
cd /openrc
gmake
gmake install
EOF

chroot ${BASEDIR} sh /config.sh
rm -f ${BASEDIR}/config.sh
rm -rf ${BASEDIR}/openrc

