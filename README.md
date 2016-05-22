desktopbsd-build
==============
## Introduction
The DesktopBSD build toolkit has been derived directly from the GhostBSD build toolkit.  GhostBSD build toolkit is directly derived from FreeSBIE toolkit, but most of the code has changed.  It has been further modified to accommodate the DesktopBSD project.
## Installing desktopbsd-build
First, you need to install git, grub2-pcbsd and grub2-efi as root user using su or sudo.
```
   pkg install git grub2-pcbsd grub2-efi
```
Second thing is to download DesktopBSD Build Toolkit.
```
   git clone https://github.com/DesktopBSD/desktopbsd-build.git
```
## Building the system
Now that the whole configuration is done, all you need to push the button:
```
   cd desktopbsd-build/mkscripts
```   
```   
   ./make_gnome_amd64_iso
```
This will build the whole system and the .iso image. To build the USB .img, you will 
additionally want to issue the following commands:
```
   ./make_gnome_amd64_img
```
##Troubleshooting
Logs are stored in:
```
   /usr/obj/gblogs/amd64/gnome
```

##Accessing the images
All resulting images will be stored in:
```
   /usr/obj/amd64/gnome
```
###Cleaning up the build environment
Now all we need to do is clean up after building (remember you can only build back after 
issuing the following commands):
````
   cd desktopbsd-build/clscripts
```

```
   ./clean_gnome_amd64
```
