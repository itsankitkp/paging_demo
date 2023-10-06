bits 32

MAGIC_NUMBER equ 0x1BADB002
ALIGN_MODULES equ 0x00000001
KERNEL_VIRTUAL_BASE equ 0xC0000000
KERNEL_PAGE_NUMBER equ (KERNEL_VIRTUAL_BASE >> 22) ; Index in the page directory

; calculate the checksum (all options + checksum should equal 0)
CHECKSUM equ -(MAGIC_NUMBER + ALIGN_MODULES)
section .multiboot.data               ;according to multiboot spec
        dd MAGIC_NUMBER           ;set magic number for
                                 ;bootloader
        dd ALIGN_MODULES         ;set flags
        dd CHECKSUM  ;set checksum

align 4096
page_directory: resb 1024
align 4096
page_table:  resb 4096

global start
extern main                      ;defined in the C file

section .multiboot.text
start:
        nop
        nop
        xor ecx, ecx ; ecx=0
        mov edi, page_table; copy address of page table
fill_page_table:
        xor eax, eax
        mov eax, ecx ;
        imul eax, 4096
        or eax, 3
        mov [edi+4*ecx], eax
        inc ecx
        cmp ecx, 1024
        jne fill_page_table

        xor ecx, ecx ; ecx=0
        mov ecx, 768 * 1024
        mov edi, 0x0010000;
fill_page_table768:
        xor eax, eax
        mov eax, edi ;
        or eax, 3
        mov [page_table+4*ecx], eax
        inc ecx
        add edi, 4096
        cmp ecx, 769 * 1024
        jne fill_page_table768

        xor ecx, ecx ; ecx=0
        mov edi, page_directory


fill_page_directory:
        mov eax, 0x00000002;
        mov [edi+4*ecx], eax
        inc ecx
        cmp ecx, 1024
        jne fill_page_directory

        mov eax, page_table
        or eax, 83
        mov [page_directory], eax

        mov eax, page_table+4*768
        or eax, 83
        mov [page_directory+4*768], eax

        ; Load the page directory base address
        mov eax, page_directory
        mov cr3, eax
        mov ebx, cr4 ; read current cr4
        or ebx, 0x00000010 ; set PSE
        mov cr4, ebx ; update cr4
        mov ebx, cr0 ; read current cr0
        or ebx, 0x80000000 ; set PG
        mov cr0, ebx; update cr0
        nop         ;cli                      ;block interrupts
        lea ebx, [higher_half] ; load the address of the label in ebx
        jmp ebx ; jump to the label

section .text
higher_half:
        mov dword [page_directory], 0
        invlpg [0]
        hlt                      ;halt the CPU



section .bss


resb 8192                        ;8KB for stack
stack_space:

