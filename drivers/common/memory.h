#ifndef MEMORY_H
#define MEMORY_H

// Memory map entry structure (E820)
typedef struct {
    uint64_t base_addr;      // Base address of memory region
    uint64_t length;         // Length of memory region
    uint32_t type;           // Memory type
    uint32_t acpi_attr;      // ACPI attributes (if supported)
} __attribute__((packed)) e820_entry_t;

// Memory map data structure
typedef struct {
    uint16_t entry_count;    // Number of entries
    e820_entry_t entries[64]; // Array of memory entries
} __attribute__((packed)) memory_map_t;

// Memory types (E820)
#define E820_TYPE_USABLE        1   // Usable memory
#define E820_TYPE_RESERVED      2   // Reserved memory
#define E820_TYPE_ACPI_RECLAIM  3   // ACPI reclaimable memory
#define E820_TYPE_ACPI_NVS      4   // ACPI non-volatile storage
#define E820_TYPE_BAD           5   // Bad memory

// Memory map location (set by bootloader)
#define MEMORY_MAP_ADDR         0x7E00

// Function to get memory map
memory_map_t* get_memory_map(void);

// Function to find usable memory regions
uint64_t find_usable_memory(uint64_t size, uint64_t alignment);

// Function to check if address is in usable memory
int is_address_usable(uint64_t addr, uint64_t size);

#endif // MEMORY_H