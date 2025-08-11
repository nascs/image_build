To build kernel and system image:

build kernel image:  (output : boot.img and out/kernel)

	bash ./build/mk-kernel.sh dragon-q6a

build one system image:  (output : system.img)

	bash ./build/mk-image.sh -c qcs6490 -t system  -r rootfs/rootfs.img
