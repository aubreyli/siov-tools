NUM=$1
modprobe dmatest
echo "install dmatest module"
sleep 1
echo 2000 > /sys/module/dmatest/parameters/timeout
echo Y > /sys/module/dmatest/parameters/norandom
echo $NUM > /sys/module/dmatest/parameters/iterations
echo 1 > /sys/module/dmatest/parameters/threads_per_chan
echo "" > /sys/module/dmatest/parameters/channel
echo 1 > /sys/module/dmatest/parameters/run
cat /sys/module/dmatest/parameters/wait
echo "dmatesting..."
sleep 1
dmesg | tail -n 10
