STARTUP(arm_start.o)
ENTRY(.reset_vectors)

MEMORY
{
	boot_rom : ORIGIN = 0x0, LENGTH = 128K	
	data_ram : ORIGIN = 0x20000 LENGTH = 128K
}

SECTIONS
{
	CODE :
	{
		arm_start.o (.reset_vectors)	
		*.o(.text)
		* (.rodata)
	} > boot_rom
	
	.= 0x10000;
	vectors_loc = .;
	.vectors vectors_loc :
	{
		KEEP(*.o(vectors))
	}

	DATA :
	{
		*	(.data)
	} > data_ram

	CODE_ALL :
	{
		*	(.text)
	} > boot_rom

	.bss :
	{
                . = ALIGN(16);
                __bss_start__ = .;
                *(.bss*)
                *(COMMON)
                . = ALIGN(16);
                __bss_end__ = .;

	} > data_ram



}



