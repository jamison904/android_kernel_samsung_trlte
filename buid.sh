#!/bin/bash

date="$(date +%Y.%m.%d_%H.%M.%S)"
target_dir="dist/${date}"

export ARCH=arm
#export CROSS_COMPILE=/home/jamison/android/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-
#export CROSS_COMPILE=/home/jamison/android/toolchain/eabi-linaro-4.8/bin/arm-eabi-
export CROSS_COMPILE=/opt/toolchains/arm-eabi-4.7/bin/arm-eabi-

mkdir -p out

make \
    O="$(pwd)/out" \
    apq8084_sec_defconfig \
    VARIANT_DEFCONFIG=apq8084_sec_trlte_eur_defconfig \
    SELINUX_DEFCONFIG=selinux_defconfig \
    SELINUX_LOG_DEFCONFIG=selinux_log_defconfig \
    TIMA_DEFCONFIG=tima_defconfig \
    DMVERITY_DEFCONFIG=dmverity_defconfig

make O="$(pwd)/out" -j8

mkdir -p "${target_dir}"
mkdir -p "${target_dir}/modules/"

# Kernel
cp out/arch/arm/boot/zImage "${target_dir}"/zImage
# Kernel modules
find out -name '*.ko' -exec cp -t "${target_dir}/modules/" {} \;
# Device tree
tools/dtbTool \
    -o "${target_dir}"/dt.img \
    -s 4096 \
    -p out/scripts/dtc/ \
    out/arch/arm/boot/dts/

echo
echo "Done! Output directory: ${target_dir}"
