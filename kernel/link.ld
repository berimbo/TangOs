OUTPUT_FORMAT(binary)
ENTRY(_start)                /* the name of the entry label */

SECTIONS {
    . = 0x1000;          /* the code should be loaded at 0x1000 */

    .text ALIGN (0x0) :
    {
        *(.text)             /* all text sections from all files */
    }

    .rodata ALIGN (0x0) :
    {
        *(.rodata*)          /* all read-only data sections from all files */
    }

    .data ALIGN (0x0) :
    {
        *(.data)             /* all data sections from all files */
    }

    .bss ALIGN (0x0) :
    {
        *(COMMON)            /* all COMMON sections from all files */
        *(.bss)              /* all bss sections from all files */
    }
}
