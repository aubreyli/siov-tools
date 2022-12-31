accel-config load-config -c ./1d1g1q_mdev_dwq.conf
accel-config enable-device dsa2
accel-config enable-wq dsa2/wq2.0
accel-config create-mdev dsa2 1dwq
