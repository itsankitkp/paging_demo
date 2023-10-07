# Paging Demo

This is small exercise meant to demonstrate setting up paging for x86 system.

## Requirements
1. NASM
2. QEMU
3. gdb

## Usage
1. make

    Compiles everything.

2. make debug

    To run in debug mode.
    Connect via gdb
    `gdb kernel.elf`
    Add breakpoint at entry point.
    To know entry point, run
    `readelf -h kernel.elf`
    Once entry point is known, add breakpoint by
    `b *0x103000`
    where 0x103000 is entry point.

    Jump into higher half and check
    x/i 0x00010000
    x/i 0xC0010000
    if they show same results.

3. make clean

    To clean up compiled files and objects.

