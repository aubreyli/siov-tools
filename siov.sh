#!/bin/bash

################################################
# Qemu debug option
#	--trace "vfio_*" \
#	--trace "migrate_*" \
#	--trace "migration_*" \
#	-D /home/aubrey/kvm/lega_mig.log \
################################################


SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo $SCRIPT_DIR
MDEV_PATH="/sys/devices/pci0000:6a/0000:6a:01.0"
KERNEL_IMAGE=/home/aubrey/kvm/vmlinux
QEMU_IMAGE=/usr/local/bin/qemu-system-x86_64
GUEST_IMAGE=/home/aubrey/kvm/debian.qcow2
UUID=`cat uuid`


: "${DEV:="no"}"
: "${IOMMU:="no"}"
: "${UUID:="off"}"

Usage()
{
    echo "Usage: $0 [-d <no|pf|mdev> ] [-i <no|lega|scal>]" 1>&2;
    exit 1;
}


[ $# -eq 0 ] && Usage

while getopts ":d:i:u:" o; do
    case "${o}" in
	d)
	    DEV=${OPTARG}
	    (($DEV == "no" || $DEV == "pf" || $DEV == "mdev")) || DEV="other"
            ;;
	i)
	    IOMMU=${OPTARG}
	    (($IOMMU == "no" || $IOMMU == "lega" || $IOMMU == "scal")) || IOMMU="other"
	    ;;
	*)
	    Usage
	    ;;
    esac
done

if [ $DEV == "other" ] || [ $IOMMU == "other" ]; then
	echo "device or iommu mode incorrect"
	Usage
fi

if [ -n "${DEV}" ]; then
    case $DEV in
	no)
	    QEMU_CMDLINE_DEVICE="-smp 2"
	    ;;
	pf)
	    QEMU_CMDLINE_DEVICE="-device vfio-pci,host=6a:01.0"
	    ;;
	mdev)
	    QEMU_CMDLINE_DEVICE="-device vfio-pci,sysfsdev=$MDEV_PATH/$UUID,x-enable-migration=on,x-enable-dynamic-mmap=on"
	    ;;
    esac
fi

if [ -n "${IOMMU}" ]; then
    case $IOMMU in
	no)
	    QEMU_CMDLINE_IOMMU="-smp 2"
	    ;;
	lega)
	    QEMU_CMDLINE_IOMMU="-device intel-iommu,caching-mode=on"
	    ;;
	scal)
	    QEMU_CMDLINE_IOMMU="-device intel-iommu,caching-mode=on,dma-drain=on,x-scalable-mode="modern",device-iotlb=on,aw-bits=48,pasid-migration=on"
	    ;;
    esac
fi

echo "============================================"
echo "device=${DEV} - iommu=${IOMMU} - uud=${UUID}"
echo "qemu cmdline iommu: ${QEMU_CMDLINE_IOMMU}"
echo "qemu cmdline device: ${QEMU_CMDLINE_DEVICE}"
echo "============================================"
echo "start vm..."
sleep 3

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
	-netdev user,id=mynet0,hostfwd=tcp::10099-:22,hostfwd=tcp::12099-:2375 \
	-monitor pty \
        -monitor telnet:127.0.0.1:9099,server,nowait \
	-drive file=${GUEST_IMAGE},if=virtio,format=qcow2 \
	-kernel ${KERNEL_IMAGE} \
	-append "root=/dev/vda1 ro console=ttyS0,115200n8 earlyprintk=ttyS0 intel_iommu=on,sm_on no5lvl idle=poll" \
	${QEMU_CMDLINE_IOMMU} \
	${QEMU_CMDLINE_DEVICE}
