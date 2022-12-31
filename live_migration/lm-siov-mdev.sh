#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo $SCRIPT_DIR

UUID=`cat uuid`
KERNEL_IMAGE=/home/aubrey/kvm/vmlinux
QEMU_IMAGE=/usr/local/bin/qemu-system-x86_64
GUEST_IMAGE=/home/aubrey/kvm/live_migration/debian.qcow2

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
	-device virtio-net-pci,netdev=mynet0,mac=00:16:3E:68:08:FF \
	-netdev user,id=mynet0,hostfwd=tcp::10098-:22,hostfwd=tcp::12098-:2375 \
	-incoming tcp:0:6666 \
	-drive file=${GUEST_IMAGE},if=virtio,format=qcow2 \
	-kernel ${KERNEL_IMAGE} \
	-append "root=/dev/vda1 ro console=ttyS0,115200n8 earlyprintk=ttyS0 intel_iommu=on,sm_on no5lvl" \
	-device intel-iommu,caching-mode=on,dma-drain=on,x-scalable-mode="modern",device-iotlb=on,aw-bits=48,pasid-migration=on \
	-device vfio-pci,sysfsdev=/sys/devices/pci0000:6f/0000:6f:01.0/$UUID,x-enable-migration=on,x-enable-dynamic-mmap=on \
