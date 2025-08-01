#include "memory.h"
#include <stdint.h>

// Get the memory map from the bootloader
memory_map_t* get_memory_map(void) {
    return (memory_map_t*)MEMORY_MAP_ADDR;
}

// Find a usable memory region of specified size and alignment
uint64_t find_usable_memory(uint64_t size, uint64_t alignment) {
    memory_map_t* map = get_memory_map();

    for (int i = 0; i < map->entry_count; i++) {
        e820_entry_t* entry = &map->entries[i];

        // Check if this is usable memory
        if (entry->type == E820_TYPE_USABLE) {
            uint64_t base = entry->base_addr;
            uint64_t end = base + entry->length;

            // Align the base address
            uint64_t aligned_base = (base + alignment - 1) & ~(alignment - 1);

            // Check if we have enough space
            if (aligned_base + size <= end) {
                return aligned_base;
            }
        }
    }

    return 0; // No suitable memory found
}

// Check if a memory address range is usable
int is_address_usable(uint64_t addr, uint64_t size) {
    memory_map_t* map = get_memory_map();
    uint64_t end = addr + size;

    for (int i = 0; i < map->entry_count; i++) {
        e820_entry_t* entry = &map->entries[i];

        // Check if this is usable memory
        if (entry->type == E820_TYPE_USABLE) {
            uint64_t entry_base = entry->base_addr;
            uint64_t entry_end = entry_base + entry->length;

            // Check if our range is completely within this usable region
            if (addr >= entry_base && end <= entry_end) {
                return 1; // Address range is usable
            }
        }
    }

    return 0; // Address range is not usable
}

// Get total usable memory size
uint64_t get_total_usable_memory(void) {
    memory_map_t* map = get_memory_map();
    uint64_t total = 0;

    for (int i = 0; i < map->entry_count; i++) {
        e820_entry_t* entry = &map->entries[i];

        if (entry->type == E820_TYPE_USABLE) {
            total += entry->length;
        }
    }

    return total;
}

// Print memory map for debugging
void print_memory_map(void) {
    memory_map_t* map = get_memory_map();

    // This would need a console/terminal driver to actually print
    // For now, we'll just store the info in a known location for debugging

    // You can access this data from your kernel's debug output
    // or by examining memory at the map location
}