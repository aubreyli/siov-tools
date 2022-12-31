modprobe vfio
modprobe vfio-pci
lspci |grep 0b25
echo 0000:6a:01.0 > /sys/bus/pci/devices/0000:6a:01.0/driver/unbind
echo 8086 0b25 > /sys/bus/pci/drivers/vfio-pci/new_id
