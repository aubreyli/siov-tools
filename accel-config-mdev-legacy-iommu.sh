modprobe idxd_mdev
accel-config load-config -c ./1d1g1q_mdev_dwq.conf
accel-config enable-device dsa0
accel-config enable-wq dsa0/wq0.0
result=`accel-config create-mdev dsa0 1dwq`
echo $result
uuid=`echo $result | awk '{ print $5 }'`
echo $uuid > uuid
