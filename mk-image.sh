#!/bin/bash -e

LOCALPATH=$(pwd)
OUT=${LOCALPATH}/out
CHIP=""
TARGET=""
ROOTFS_PATH=""
BOARD=""

source $LOCALPATH/build/partitions.sh

usage() {
	echo -e "\nUsage: build/mk-image.sh -c qcs6490 -t system -r rootfs/rootfs.ext4 \n"
}
finish() {
	echo -e "\e[31m MAKE IMAGE FAILED.\e[0m"
	exit -1
}
trap finish ERR

OLD_OPTIND=$OPTIND
while getopts "c:t:r:b:h" flag; do
	case $flag in
		c)
			CHIP="$OPTARG"
			;;
		t)
			TARGET="$OPTARG"
			;;
		r)
			ROOTFS_PATH="$OPTARG"
			;;
		b)
			BOARD="$OPTARG"
			;;
	esac
done
OPTIND=$OLD_OPTIND

if [ ! $CHIP ] && [ ! $TARGET ]; then
	usage
	exit
fi

generate_boot_image() {
	BOOT=${OUT}/boot.img
	rm -rf ${BOOT}

	echo -e "\e[36m Generate Boot image start\e[0m"

	mkfs.vfat -n "boot" -S 512 -C ${BOOT} $((100 * 1024))

	mcopy -i ${BOOT} -s ${LOCALPATH}/build/boot/* ::
	mcopy -i ${BOOT} -s ${OUT}/kernel/* ::

	echo -e "\e[36m Generate Boot image : ${BOOT} success! \e[0m"
}

generate_system_image() {
	if [ ! -f "${OUT}/boot.img" ]; then
		echo -e "\e[31m CAN'T FIND BOOT IMAGE \e[0m"
		usage
		exit
	fi

	if [ ! -f "${ROOTFS_PATH}" ]; then
		echo -e "\e[31m CAN'T FIND ROOTFS IMAGE \e[0m"
		usage
		exit
	fi

	SYSTEM=${OUT}/system.img
	rm -rf ${SYSTEM}

	echo "Generate System image : ${SYSTEM} !"

	# last dd rootfs will extend gpt image to fit the size,
	# but this will overrite the backup table of GPT
	# will cause corruption error for GPT
	IMG_ROOTFS_SIZE=$(stat -L --format="%s" ${ROOTFS_PATH})
	GPTIMG_MIN_SIZE=$(expr $IMG_ROOTFS_SIZE + \( ${BOOT_START} + ${BOOT_SIZE} + 35 \) \* 512)
	GPT_IMAGE_SIZE=$(expr $GPTIMG_MIN_SIZE \/ 1024 \/ 1024 + 2)

	dd if=/dev/zero of=${SYSTEM} bs=1M count=0 seek=$GPT_IMAGE_SIZE

	parted -s ${SYSTEM} mklabel gpt
	parted -s ${SYSTEM} unit s mkpart boot ${BOOT_START} $(expr ${ROOTFS_START} - 1)
	parted -s ${SYSTEM} set 1 boot on
	parted -s ${SYSTEM} -- unit s mkpart rootfs ${ROOTFS_START} -34s

	ROOT_UUID="614e0000-0000-4b53-8000-1d28000054a9"

	gdisk ${SYSTEM} <<EOF
x
c
2
${ROOT_UUID}
w
y
EOF

	# burn boot image
	dd if=${OUT}/boot.img of=${SYSTEM} conv=notrunc seek=${BOOT_START}

	# burn rootfs image
	dd if=${ROOTFS_PATH} of=${SYSTEM} conv=notrunc,fsync seek=${ROOTFS_START}
}

if [ "$TARGET" = "boot" ]; then
	generate_boot_image
elif [ "$TARGET" == "system" ]; then
	generate_system_image
fi
