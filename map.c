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

void usage(void)
{
	printf("./map [iova] [vaddr]\n");
}

int main(int argc, char **argv)
{
	uint64_t iova, vaddr;
	int vfio_fd = -1;
	int ret = -1;
	int i;

	struct vfio_iommu_type1_dma_map map = {
		.argsz = sizeof(map),
		.flags = VFIO_DMA_MAP_FLAG_READ | VFIO_DMA_MAP_FLAG_WRITE,
		.iova = 0x100000000,
		.size = 0x200000,
	};

	if (argc < 2) {
		usage();
		return 0;
	}

	iova = strtoul(argv[1], NULL, 16);
	vaddr = strtoul(argv[2], NULL, 16);
	printf("iova:0x%llx, vaddr:0x%llx, size:0x200000\n", (__u64)iova, (__u64)vaddr);

	map.iova = iova;
	map.vaddr = vaddr + iova - 0x100000000;

	vfio_fd = open(VFIO_PATH, O_RDWR);
        if(vfio_fd < 0) {
                printf("Failed to open vfio device!\n");
                return -EINVAL;
        }
	ret = ioctl(vfio_fd, VFIO_USER_MAP, &map);
	printf("map ret: %d\n", ret);

	return ret;
}
