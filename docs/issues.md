# Issue Tracker

## Implementing Kernel

-   Changed the bootloader to load the kernel. Now getting disk read error
    -   Legit just started working idk how
-   Bootloader is now found but stuck loading kernel
    -   Couldn't find the boot signature
-   Kernel is somehow jumping back to the bootloader
    -   Its not even the kernel some random bytes are just executing and it thinks its the kernel
    -   5 hours later it works
