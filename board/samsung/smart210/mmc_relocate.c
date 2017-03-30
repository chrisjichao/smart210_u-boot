typedef unsigned int (*copy_sd_mmc_to_mem) (unsigned int  channel, unsigned int  start_block, unsigned char block_size, unsigned int  *trg, unsigned int  init);


void copy_code_to_dram(void)
{
	unsigned long ch;
	unsigned long dest = 0x34800000;
	unsigned int  sec_no = 49;

	unsigned long uImage_dest = 0x30008000;
	unsigned int  uImage_sec_no = 1000;

	unsigned long fs_dest = 0x21000000;
	unsigned int fs_sec_no = 100000;	

	unsigned int ret, i;

	ch = *(volatile unsigned int *)(0xD0037488);

	copy_sd_mmc_to_mem copy_bl2 = (copy_sd_mmc_to_mem) (*(unsigned int *) (0xD0037F98));
	
	if (ch == 0xEB000000)
	{
		// 0:channel 0
		// 49:secter num, 1 sector = 512 bytes
		ret = copy_bl2(0, sec_no,       128,(unsigned int *)dest, 0);
		ret = copy_bl2(0, sec_no + 128, 128,(unsigned int *)(dest + 0x10000), 0);
		ret = copy_bl2(0, sec_no + 256, 128,(unsigned int *)(dest + 0x20000), 0);
		ret = copy_bl2(0, sec_no + 384, 128,(unsigned int *)(dest + 0x30000), 0);
		
		for(i = 0; i < 5*1024; i++) {
			copy_bl2(0, uImage_sec_no + i*2, 2, (unsigned int *)(uImage_dest + i*1024), 0);
		}
		/*
		for(i = 0; i < 18*1024; i++) 
			copy_bl2(0, fs_sec_no + i*2, 2, (unsigned int *)(fs_dest + i*1024), 0);
		*/
	}
}
