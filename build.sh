#!/bin/bash

export SUBARCH=arm
export ARCH=arm
export CROSS_COMPILE=/home/lowi/Daten/KERNEL/git/linaro_toolchains_2014/arm-cortex_a15-linux-gnueabihf-linaro_4.9.3-2014.12/bin/arm-cortex_a15-linux-gnueabihf-

make -j10

rm -rf mod
mkdir mod

cp `find ./ | grep .ko$` modules.order mod/

rm -rf out
mkdir out

find /home/lowi/Daten/KERNEL/flashable_zip/ -name "*-kernel-*.zip" -exec cp {} /home/lowi/Daten/KERNEL/git/android_kernel_samsung_hlte/out \;

~/Daten/KERNEL/boot_tools/x64/dtbTool -s 2048 -o arch/arm/boot/dt.img -p scripts/dtc/ arch/arm/boot/
cp arch/arm/boot/zImage out/zImage
cp arch/arm/boot/dt.img out/dt.img
~/Daten/KERNEL/boot_tools/x64/mkbootfs ramdisk/ | gzip > out/ramdisk.gz
~/Daten/KERNEL/boot_tools/x64/mkbootimg --kernel out/zImage --ramdisk out/ramdisk.gz --dt out/dt.img --cmdline "console=null androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x3F androidboot.bootdevice=msm_sdcc.1 androidboot.selinux=permissive" --base 0x26fff00 --ramdisk_offset 0x2900000 --tags_offset 0x2700000 --pagesize 2048 -o out/boot.img

cd out
find . -name "*-kernel-*.zip" -exec zip -d {} boot.img \;
find . -name "*-kernel-*.zip" -exec zip -u {} boot.img \;
cd ..

if [ $# -eq 0 ]
  then
    echo "\n\n  no version specified for flashable zip\n  use sh build.sh -33 for setting version to 33!\n  overwriting archive:"
    echo "  --> `find out/ -name "*-kernel-*.zip"`\n\n"
else
  flashable_zip_orig=`find out/ -name "*-kernel-*.zip"`
  flashable_zip_new=$(echo $flashable_zip_orig | sed "s/-001/$1/g")
  mv $flashable_zip_orig $flashable_zip_new
fi
