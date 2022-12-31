#!/bin/bash

UUID=b7930115-bcf3-4ab6-98f1-285f282740af

KERNEL_IMAGE=/home/aubrey/kvm/vmlinuz-5.10.112-vdcm2
QEMU_IMAGE=/usr/local/bin/qemu-system-x86_64
GUEST_IMAGE=/home/aubrey/kvm/live_migration/lm_debian.qcow2

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
	-netdev user,id=mynet0,hostfwd=tcp::10098-:22,hostfwd=tcp::12098-:2375 \
	-incoming tcp:0:6666 \
	-monitor pty \
        -monitor telnet:127.0.0.1:9098,server,nowait \
	-drive file=${GUEST_IMAGE},if=virtio,format=qcow2 \
	-kernel ${KERNEL_IMAGE} \
	-append "root=/dev/vda1 ro console=ttyS0,115200n8 earlyprintk=ttyS0 intel_iommu=on,sm_on no5lvl idle=poll" \
