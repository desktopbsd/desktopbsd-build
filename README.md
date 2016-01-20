desktopbsd-build
==============
## Introduction
The DesktopBSD build toolkit has been derived directly from the GhostBSD build toolkit.  GhostBSD build toolkit is directly derived from FreeSBIE toolkit, but most of the code changed.  The ghostbsd-build toolkit has been designed to allow developers to building both, i386 and amd64 architectures on amd64 architectures. The ghostbsd-build to can build GhostBSD on FreeBSD, PCBSD and GhostBSD.
## Installing ghostbsd-build
First, you need to install git as root user using su or sudo.
```
pkg install git
```
Second thing is to download DesktopBSD Build Toolkit.
```
git clone https://github.com/DesktopBSD/desktopbsd-build.git
```

## Configuring the system

Have a look in ghostbsd-build/conf/ghostbsd.defaults.conf - you will notice very important lines 
below:
```
   NO_BUILDWORLD=YES
   NO_BUILDKERNEL=YES
```
Comment these two lines the first time you run the building process for each Architectures. The next time you run it, 
you can uncomment them - it will then save you quite some time (you simply do not need to 
rebuild your kernel and world every time unless you’ve committed significant changes to them).

## Building the system

Now that the whole configuration is done, all you need to push the button:

   cd desktopbsd-build/mkscripts
   ./make_gnome_amd64_iso

This will build the whole system and the .iso image. To build the USB .img, you will 
additionally want to issue the following commands:

   ./make_gnome_amd64_img

Now all we need to do is clean up after building (remember you can only build back after 
issuing the following commands):

   cd desktopbsd-build/clscripts
   clean_gnome_amd64
