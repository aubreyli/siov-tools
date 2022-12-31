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
	uint64_t vaddr;
	int vfio_fd = -1;
	int ret = -1;
	int i;
	int length = 3072;
	__u64 iova_base = 0x100000000;
	size_t size = 0x200000;

	struct vfio_iommu_type1_dma_unmap unmap = {
		.argsz = sizeof(unmap),
		.flags = 0,
		.iova = 0x100000000,
		.size = 0x180000000,
	};

	struct vfio_iommu_type1_dma_map map = {
		.argsz = sizeof(map),
		.flags = VFIO_DMA_MAP_FLAG_READ | VFIO_DMA_MAP_FLAG_WRITE,
		.iova = 0x100000000,
		.size = 0x200000,
	};


	vfio_fd = open(VFIO_PATH, O_RDWR);
        if(vfio_fd < 0) {
                printf("Failed to open vfio device!\n");
                return -EINVAL;
        }
	ret = ioctl(vfio_fd, VFIO_USER_UNMAP, &unmap);
	printf("unmap ret: %d, unmapped size: 0x%llx\n", ret, (__u64)unmap.size);

	vaddr = strtoul(argv[1], NULL, 16);
	printf("0x%llx\n", (__u64)vaddr);

	vfio_fd = open(VFIO_PATH, O_RDWR);
        if(vfio_fd < 0) {
                printf("Failed to open vfio device!\n");
                return -EINVAL;
        }

	for (i = 0; i < length; i++) {
		map.iova = iova_base + i * size;
		map.vaddr = vaddr + i * size;
		ret = ioctl(vfio_fd, VFIO_USER_MAP, &map);
		printf("map ret: %d\n", ret);
	}

	return ret;
}
