#!/bin/bash

DEVUUID=cc6bb29d-0ea7-4d97-af76-c0ccaafb11e9
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo $SCRIPT_DIR

#KERNEL_IMAGE=/home/aubrey/kvm/vmlinuz-5.15.0-siov+
KERNEL_IMAGE=/home/aubrey/kvm/vmlinuz-5.10.112-siov
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
	-smp 8 \
	-m 8G \
	-machine q35 \
	-nographic \
	-vga none \
	-device virtio-net-pci,netdev=mynet0,mac=00:16:3E:68:08:FF \
	-netdev user,id=mynet0,hostfwd=tcp::10099-:22,hostfwd=tcp::12099-:2375 \
	-monitor pty \
        -monitor telnet:127.0.0.1:9099,server,nowait \
	-drive file=${GUEST_IMAGE},if=virtio,format=qcow2 \
#	-kernel ${KERNEL_IMAGE} \
#	-append "root=/dev/vda1 ro console=ttyS0,115200n8 earlyprintk=ttyS0 intel_iommu=on,sm_on no5lvl idle=poll" \
#	-device intel-iommu,caching-mode=on \
#	-device vfio-pci,sysfsdev=/sys/devices/pci0000:6a/0000:6a:01.0/$DEVUUID,rombar=0,x-enable-migration=on \
