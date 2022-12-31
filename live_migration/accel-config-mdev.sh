if [ ! -n "$1" ]; then
	echo "Usage: ./accel-config-mdev.sh [enable | disable] [dwq | swq]"
	exit 0
fi

if [ ! -n "$2" ]; then
	echo "Usage: ./accel-config-mdev.sh [enable | disable] [dwq | swq]"
	exit 0
fi

if [ $1 = 'enable' ]; then
	accel-config load-config -c ./1d1g1q_mdev_$2.conf
	accel-config enable-device dsa2
	accel-config enable-wq dsa2/wq2.0
	if [ $2 = 'swq' ]; then
		result=`accel-config create-mdev dsa2 1swq`
	fi
	if [ $2 = 'dwq' ]; then
		result=`accel-config create-mdev dsa2 1dwq`
	fi
	echo $result
	uuid=`echo $result | awk '{ print $5 }'`
	echo $uuid > uuid
	cat uuid
	echo "DSA $2 enabled!"
fi

if [ $1 = 'disable' ]; then
	uuid=`cat uuid`
	accel-config remove-mdev dsa2 $uuid
	accel-config disable-wq dsa2/wq2.0
	accel-config disable-device dsa2
	echo "DSA $2 disabled!"
fi
