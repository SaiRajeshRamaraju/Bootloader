bits 16
org 0x7C00

start:
    ; Set up segment registers
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00  ; Setup stack pointer near top of segment

    ; Switch to protected mode
    cli
    lgdt [gdt_descriptor]
    mov ebx, cr0
    or ebx, 0x1
    mov cr0, ebx
    jmp 0x8:init_pm

bits 32
init_pm:
    mov bx, 0x10
    mov ds, bx
    mov es, bx
    mov fs, bx
    mov gs, bx
    mov ss, bx
    mov esp, 0x7C00
    
    ; Setup Multiboot signature to pass to kernel
    mov eax, 0x2BADB002 ; Multiboot magic
    mov ebx, 0x7000     ; dummy address of Multiboot info

    ; Directly jump to the kernel loaded at 1MB
    mov ecx, 0x100000
    jmp ecx
    
hang:
    hlt
    jmp hang

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

gdt_start:
    dq 0x0
gdt_code:     ; CS will point to this selector
    dw 0xFFFF ; Limit (low)
    dw 0x0    ; Base (low)
    db 0x0    ; Base (middle)
    db 10011010b ; Access: Present, Ring 0, Code, Exec/Read
    db 11001111b ; Flags: 4KB gran, 32-bit, Limit (high)
    db 0x0    ; Base (high)
gdt_data:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10010010b ; Access: Present, Ring 0, Data, Read/Write
    db 11001111b
    db 0x0
gdt_end:

times 510 - ($ - $$) db 0
dw 0xAA55
