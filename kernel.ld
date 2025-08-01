ENTRY(start)

SECTIONS {
    . = 0x100000; /* Kernel loads at 1MB */

    /* Text (code + rodata) */
    .text : {
        *(.text)
        *(.rodata*)
    }

    /* Data (initialized globals) */
    .data : {
        __data_start = .;
        *(.data)
        __data_end = .;
    }

    /* BSS (zero-initialized globals) */
    .bss : {
        __bss_start = .;
        *(.bss)
        *(COMMON)
        __bss_end = .;
    }

    /* Data load address in the file */
    __data_load = LOADADDR(.data);
}
