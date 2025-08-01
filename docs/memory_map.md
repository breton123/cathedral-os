# E820 Memory Map Implementation

## Overview

The bootloader now implements the E820 memory map functionality, which provides detailed information about the system's memory layout. This is essential for proper memory management in the kernel.

## How It Works

### Bootloader (stage2.asm)

1. **Memory Map Location**: The memory map is stored at physical address `0x7E00`
2. **Data Structure**:
   - Entry count (16-bit)
   - Array of up to 64 memory entries (20 bytes each)
3. **E820 Call**: Uses INT 15h with EAX=0xE820 to query BIOS for memory regions

### Memory Entry Structure

Each memory entry contains:
- `base_addr` (64-bit): Starting address of memory region
- `length` (64-bit): Size of memory region in bytes
- `type` (32-bit): Memory type (see below)
- `acpi_attr` (32-bit): ACPI attributes (if supported)

### Memory Types

- `1`: Usable memory (available for use)
- `2`: Reserved memory (not available)
- `3`: ACPI reclaimable memory
- `4`: ACPI non-volatile storage
- `5`: Bad memory (should be avoided)

## Usage in Kernel

### Accessing the Memory Map

```c
#include "drivers/common/memory.h"

// Get the memory map
memory_map_t* map = get_memory_map();

// Access entry count
uint16_t count = map->entry_count;

// Access individual entries
for (int i = 0; i < count; i++) {
    e820_entry_t* entry = &map->entries[i];
    printf("Region %d: 0x%llx - 0x%llx, type %d\n",
           i, entry->base_addr, entry->base_addr + entry->length, entry->type);
}
```

### Finding Usable Memory

```c
// Find 1MB of usable memory aligned to 4KB
uint64_t addr = find_usable_memory(1024*1024, 4096);
if (addr != 0) {
    printf("Found usable memory at 0x%llx\n", addr);
}
```

### Checking Memory Usability

```c
// Check if a specific address range is usable
if (is_address_usable(0x100000, 1024*1024)) {
    printf("Address range is usable\n");
}
```

### Getting Total Usable Memory

```c
uint64_t total = get_total_usable_memory();
printf("Total usable memory: %llu bytes (%llu MB)\n",
       total, total / (1024*1024));
```

## Debug Information

The kernel stores debug information at:
- `0x10000`: VESA and basic memory map info
- `0x10100`: Detailed memory map entries

You can examine these locations in a debugger to verify the memory map is working correctly.

## Memory Layout

```
0x0000 - 0x1000: Bootloader
0x1000 - 0x1200: Kernel
0x1200 - 0x2000: Stage 2 bootloader
0x7E00 - 0x8200: Memory map data
0x8200 - 0x8300: VESA screen info
0x10000: Debug info
```

## Notes

- The memory map is obtained before switching to protected mode
- Up to 64 memory entries are supported
- The implementation handles both 32-bit and 64-bit memory addresses
- Memory regions are automatically sorted by the BIOS
- Reserved memory should never be used for kernel operations