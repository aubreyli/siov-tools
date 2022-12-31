#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo $SCRIPT_DIR

KERNEL_IMAGE=/home/aubrey/kvm/vmlinux
QEMU_IMAGE=/usr/local/bin/qemu-system-x86_64
GUEST_IMAGE=/home/aubrey/kvm/debian.qcow2

if [[ ! -f $QEMU_IMAGE ]]; then
	echo "Qemu image $QEMU_IMAGE does not exist"
	exit 1
else
	echo "Using Qemu binary $QEMU_IMAGE"
fi


$QEMU_IMAGE \
	-accel kvm \
	-cpu host \
	-smp 2 \
	-m 8G \
	-machine q35 \
	-nographic \
	-vga none \
	-device virtio-net-pci,netdev=mynet0,mac=00:16:3E:68:08:FF,romfile= \
	-netdev user,id=mynet0,hostfwd=tcp::10099-:22,hostfwd=tcp::12099-:2375 \
	-drive file=${GUEST_IMAGE},if=virtio,format=qcow2 \
	-kernel ${KERNEL_IMAGE} \
	-append "root=/dev/vda1 ro console=ttyS0,115200n8 earlyprintk=ttyS0 intel_iommu=on,sm_on" \
	-device intel-iommu,caching-mode=on,dma-drain=on,x-scalable-mode="modern",device-iotlb=on,aw-bits=48 \
	-device vfio-pci,host=6a:01.0 \
