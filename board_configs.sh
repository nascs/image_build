#!/bin/bash -e

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-

BOARD=$1
DEFCONFIG=""
DTB=""
KERNELIMAGE=""
CHIP=""
UBOOT_DEFCONFIG=""

case ${BOARD} in
	"dragon-q6a")
		DEFCONFIG=qcmini_defconfig
		DTB=qcs6490-radxa-dragon-q6a.dtb
		export ARCH=arm64
		export CROSS_COMPILE=aarch64-linux-gnu-
		CHIP="qcs6490"
		;;
	"airbox-q900")
		DEFCONFIG="qcom_defconfig qcom_addons.config"
		DTB=qcs9075-radxa-airbox-q900.dtb
		export ARCH=arm64
		export CROSS_COMPILE=aarch64-linux-gnu-
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
