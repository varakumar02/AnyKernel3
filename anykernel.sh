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
# Purge only when both hold: no vendor_dlkm.img in the zip and Android 16 or
# newer. Otherwise the ramdisk modules.* stay as they are.
# The Android version is the one AK3's own version check detected
# (AK_ANDROID_VER, exported by update-binary); the SDK level is the fallback
# when that is missing or not a plain number (e.g. a preview codename).
android=${AK_ANDROID_VER%%.*};
case "$android" in
  ''|*[!0-9]*)
    sdk=$(file_getprop /system/build.prop ro.build.version.sdk);
    [ "$sdk" ] || sdk=$(getprop ro.build.version.sdk 2>/dev/null);
    case "$sdk" in
      ''|*[!0-9]*) android="";;
      *) [ "$sdk" -ge 36 ] && android=16 || android=15;;
    esac;;
esac;
if [ ! -f "$AKHOME/vendor_dlkm.img" ] && [ "$android" ] && [ "$android" -ge 16 ]; then
  ui_print "->No vendor_dlkm.img on Android $android: purging stale ramdisk module dependency...";
  find $RAMDISK -name "modules.*" -delete;
else
  ui_print "->Keeping ramdisk module dependency (vendor_dlkm.img in zip or Android ${android:-unknown})";
fi

write_boot;
## end vendor_boot install
