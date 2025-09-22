#!/bin/bash -e

export ARCH=arm64
export CROSS_COMPILE=/tank3/william/toolchain/arm-gnu-toolchain-12.2.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-

BOARD=$1
DEFCONFIG=""
DTB=""
KERNELIMAGE=""
CHIP=""
UBOOT_DEFCONFIG=""

case ${BOARD} in
	"airbox-q900")
		DEFCONFIG=qcom_defconfig
		DTB=qcs9075-radxa-airbox-q900.dtb
		export ARCH=arm64
		export CROSS_COMPILE=/tank3/william/toolchain/arm-gnu-toolchain-12.2.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-
		CHIP="qcs9075"
		;;
	*)
		echo "board '${BOARD}' not supported!"
		exit -1
		;;
esac

#build on native arm64
if [ "X$(uname -m)" == "Xaarch64" -a "X${ARCH}" == "Xarm64" ]; then
        unset ARCH
        unset CROSS_COMPILE
fi
