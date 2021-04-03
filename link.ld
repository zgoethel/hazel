ENTRY(boot)

SECTIONS
{
    . = 1M;
    
    .boot :
    {
        /*
         * Boot header data
         */
        KEEP(*(.multiboot))
    }
    
    .text :
    {
        /*
         * Program instructions
         */
        *(.text)
    }
    
    .rodata :
    {
        /*
         * Read-only data
         */
        *(.rodata)
    }
    
    .bss :
    {
        /*
         * Reserved space
         */
        *(.bss)
    }
}
