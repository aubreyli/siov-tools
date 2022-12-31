echo 0000:6a:01.0 > /sys/bus/pci/drivers/vfio-pci/unbind
echo 8086 0b25 > /sys/bus/pci/drivers/vfio-pci/remove_id
echo 0000:6a:01.0 > /sys/bus/pci/drivers/idxd/bind
