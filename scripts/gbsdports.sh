#!/bin/sh
#
# Copyright (c) 2011 GhostBSD
#
# See COPYING for licence terms.
#
# $GhostBSD$
# $Id: gbsdports.sh,v 1.7 Thu Jun 23 10:04:31 AST 2015 Angelescu Ovidiu


if [ -z "${LOGFILE:-}" ]; then
    echo "This script can't run standalone."
    echo "Please use launch.sh to execute it."
    exit 1
fi

if [ ! -f "/usr/local/bin/git" ]; then
  echo "Install Git to fetch pkg from GitHub"
  exit 1
fi

PKGFILE=${PKGFILE:-${LOCALDIR}/conf/${PACK_PROFILE}-ghostbsd};

#if [ ! -f ${PKGFILE} ]; then
 # return
#fi
touch ${PKGFILE}

# Search main file package for include dependecies
# and build an depends file ( depends )
awk '/^ghostbsd_deps/,/^"""/' ${LOCALDIR}/packages/${PACK_PROFILE} | grep -v '"""' | grep -v '#' > ${LOCALDIR}/packages/${PACK_PROFILE}-gdepends

# If exist an old .packages file removes it
if [ -f ${LOCALDIR}/conf/${PACK_PROFILE}-ghostbsd ] ; then
  rm -f ${LOCALDIR}/conf/${PACK_PROFILE}-ghostbsd
fi

# Reads depends file and search for packages entries in each file from depends
# list, then append all packages found in ghostbsd file
while read pkgs ; do
awk '/^packages/,/^"""/' ${LOCALDIR}/packages/ghostbsd.d/$pkgs  >> ${LOCALDIR}/conf/${PACK_PROFILE}-gpackage
done < ${LOCALDIR}/packages/${PACK_PROFILE}-gdepends

# Removes """ and # from temporary package file
cat ${LOCALDIR}/conf/${PACK_PROFILE}-gpackage | grep -v '"""' | grep -v '#' > ${LOCALDIR}/conf/${PACK_PROFILE}-ghostbsd

# Removes temporary files
if [ -f ${LOCALDIR}/conf/${PACK_PROFILE}-gpackage ] ; then
  rm -f ${LOCALDIR}/conf/${PACK_PROFILE}-gpackage
  rm -f ${LOCALDIR}/packages/${PACK_PROFILE}-gdepends
fi

cp -f ${PKGFILE} ${BASEDIR}/mnt

if ! ${USE_JAILS} ; then
    if [ -z "$(mount | grep ${BASEDIR}/var/run)" ]; then
        mount_nullfs /var/run ${BASEDIR}/var/run
    fi
fi
cp -af /etc/resolv.conf ${BASEDIR}/etc

install_and_build_dports()
{
# Compiling ghostbsd ports
if [ -d ${BASEDIR}/ports ]; then
  rm -Rf ${BASEDIR}/ports
fi
#mkdir -p ${BASEDIR}/usr/ports

echo "# Downloading ghostbsd ports from GitHub #"
git clone https://github.com/desktopbsd/desktopbsd-ports.git ${BASEDIR}/ports >/dev/null 2>&1
cp -Rf $BASEDIR/ports/ $BASEDIR/dist/ports

# build ghostbsd ports 
cp -af ${PKGFILE} ${BASEDIR}/mnt
PLOGFILE=".log_portsinstall"

cat > ${BASEDIR}/mnt/portsbuild.sh << "EOF"
#!/bin/sh 

pkgfile="${PACK_PROFILE}-ghostbsd"
FORCE_PKG_REGISTER=true
export FORCE_PKG_REGISTER
PLOGFILE=".log_portsinstall"
ln -sf /dist/ports /usr/ports

cd /mnt

while read pkgc; do
    if [ -n "${pkgc}" ] ; then
        echo "Building and installing port $pkgc"
        # builds ghostbsd ports in chroot
        for port in $(find /ports/ -type d -depth 2 -name ${pkgc})  ; do
        cd $port
        make >> /mnt/${PLOGFILE} 2>&1 
        make install >> /mnt/${PLOGFILE} 2>&1 
        done
    fi
done < $pkgfile

rm -f /mnt/portsbuild.sh
rm -f /mnt/$pkgfile

EOF


# Build and install ghostbsd ports in chroot 
chrootcmd="chroot ${BASEDIR} sh /mnt/portsbuild.sh"
$chrootcmd

rm -Rf ${BASEDIR}/ports
}

install_repo_dports()
{
# Make /usr/local/etc/pkg/repos dir to store needed repos
mkdir -p ${BASEDIR}/usr/local/etc/pkg/repos

# Make certificate dir for distro packages and fetch needed cert
mkdir -p ${BASEDIR}/usr/local/etc/ssl/certs
cd ${BASEDIR}/usr/local/etc/ssl/certs
fetch http://skynet.desktopbsd.net/certs/poudriere.cert
cd .

### Repos creation
cat > ${BASEDIR}/usr/local/etc/pkg/repos/DesktopBSD.conf << "EOF"
# To disable this repository, instead of modifying or removing this file,
# create a /usr/local/etc/pkg/repos/DesktopBSD.conf file:
#
#   echo "DesktopBSD: { enabled: no }" > /usr/local/etc/pkg/repos/DesktopBSD.conf

DesktopBSD: {
  url: "pkg+http://skynet.desktopbsd.net/packages/10amd64-2016Q2",
  mirror_type: "srv",
  signature_type: "pubkey",
  pubkey: "/usr/local/etc/ssl/certs/poudriere.cert",
  enabled: yes
}
EOF

cat > ${BASEDIR}/usr/local/etc/pkg/repos/FreeBSD.conf << "EOF"
# To disable this repository, instead of modifying or removing this file,
# create a /usr/local/etc/pkg/repos/FreeBSD.conf file:
#
#   echo "FreeBSD: { enabled: no }" > /usr/local/etc/pkg/repos/FreeBSD.conf

FreeBSD: {
  enabled: yes
}
EOF

cat > ${BASEDIR}/mnt/addpkg.sh << "EOF"
#!/bin/sh 

pkgfile="${PACK_PROFILE}-ghostbsd"
FORCE_PKG_REGISTER=true
export FORCE_PKG_REGISTER
PLOGFILE=".log_portsinstall"
pkgaddcmd="pkg install -y "

#updates package list
pkg update

cd /mnt

while read pkgc; do
    if [ -n "${pkgc}" ] ; then
    echo "Installing package $pkgc"
    echo "Running $pkgaddcmd ${pkgc}" >> ${PLOGFILE} 2>&1
    $pkgaddcmd $pkgc >> ${PLOGFILE} 2>&1
    fi
done < $pkgfile

rm addpkg.sh
rm $pkgfile
EOF

# Install ghostbsd ports from repo in chroot 
chrootcmd="chroot ${BASEDIR} sh /mnt/addpkg.sh"
$chrootcmd

# Reenable FreeBSD repo
rm -f ${BASEDIR}/usr/local/etc/pkg/repos/FreeBSD.conf
}

if ! ${USE_DISTROREPO} ; then
    install_and_build_dports
else
    install_repo_dports
fi

# save logfile where should be
PLOGFILE=".log_portsinstall"
mv ${BASEDIR}/mnt/${PLOGFILE} ${MAKEOBJDIRPREFIX}/${LOCALDIR}

# umount /var/run if not using jails
if ! ${USE_JAILS} ; then
    if [ -n "$(mount | grep ${BASEDIR}/var/run)" ]; then
        umount ${BASEDIR}/var/run
    fi
fi
rm ${BASEDIR}/etc/resolv.conf

