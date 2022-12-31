#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/vfio.h>


#define VFIO_PATH "/dev/vfio/vfio"
#define VFIO_USER_UNMAP                      _IO(VFIO_TYPE, VFIO_BASE + 32)
#define VFIO_USER_MAP                        _IO(VFIO_TYPE, VFIO_BASE + 33)

int main(int argc, char **argv)
{
	int vfio_fd = -1;
	int ret = -1;
	int i;
	__u64 iova;
	struct vfio_iommu_type1_dma_unmap unmap = {
		.argsz = sizeof(unmap),
		.flags = 0,
		.iova = 0x100000000,
		.size = 0x200000,
	};

	iova = strtoul(argv[1], NULL, 16);
	printf("0x%llx\n", (__u64)iova);

	vfio_fd = open(VFIO_PATH, O_RDWR);
        if(vfio_fd < 0) {
                printf("Failed to open vfio device!\n");
                return -EINVAL;
        }
	unmap.iova = iova;
	ret = ioctl(vfio_fd, VFIO_USER_UNMAP, &unmap);
	printf("unmap ret: %d, unmapped iova - 0x%llx  size - 0x%llx\n", ret, iova, (__u64)unmap.size);

	return ret;
}
