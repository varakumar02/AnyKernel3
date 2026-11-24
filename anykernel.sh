### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers
# Levion changes by Tony

### AnyKernel setup
# global properties
properties() { '
kernel.string=### Levion Kernel for OnePlus 9/Pro ###
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=OnePlus9Pro
device.name2=lemonadep
device.name3=OnePlus9ProTMO
device.name4=lemonadept
device.name5=OnePlus9
device.name6=lemonade
device.name7=OnePlus9TMO
device.name8=lemonadet
device.name9=OnePlus9VZW
device.name10=lemonadev
supported.versions=15-17
'; } # end properties


## trim partitions
fstrim -v /data;

### AnyKernel install
## boot files attributes
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/overlay.d/*;
set_perm_recursive 0 0 750 750 $RAMDISK/overlay.d/sbin;
} # end attributes

# boot shell variables
BLOCK=boot;
IS_SLOT_DEVICE=1;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;
NO_VBMETA_PARTITION_PATCH=1;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
dump_boot;

write_boot;
## end boot install


## vendor_boot files attributes
vendor_boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
} # end attributes

# vendor_boot shell variables
BLOCK=vendor_boot;
IS_SLOT_DEVICE=1;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;
NO_VBMETA_PARTITION_PATCH=1;

# reset for vendor_boot patching
reset_ak;

# vendor_boot install
dump_boot;

# A modules-less (built-in) kernel ships no vendor_dlkm.img in the zip; its
# ramdisk modules.* still reference drivers that are now built into the image,
# so purge them (from Madara273/AnyKernel3@9814fccb). A modular build ships
# vendor_dlkm.img with valid module metadata -- leave the ramdisk untouched.
# Purge only without vendor_dlkm.img and on Android 16+ (the version AK3's
# version check found; SDK 36+ when that is not a plain number).
v=${AK_ANDROID_VER%%.*};
case $v in ''|*[!0-9]*) [ "$(file_getprop /system/build.prop ro.build.version.sdk)" -ge 36 ] 2>/dev/null && v=16;; esac;
if [ ! -f "$AKHOME/vendor_dlkm.img" ] && [ "$v" -ge 16 ] 2>/dev/null; then
  ui_print "->No vendor_dlkm.img on Android $v: purging stale ramdisk module dependency...";
  find $RAMDISK -name "modules.*" -delete;
else
  ui_print "->Keeping ramdisk module dependency (vendor_dlkm.img in zip or Android ${v:-unknown})";
fi

write_boot;
## end vendor_boot install
