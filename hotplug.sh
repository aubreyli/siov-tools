UUID=`cat uuid`
echo "device_add vfio-pci,sysfsdev=/sys/bus/pci/devices/0000:6a:01.0/$UUID,id=dsa0,bus=root"
