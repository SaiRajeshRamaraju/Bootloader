bits 16
org 0x7C00

start:
    ; Set up segment registers
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00  ; Setup stack pointer near top of segment

    ; Write 'A' to serial to show we're alive
    mov dx, 0x3F8
    mov al, 'A'
    out dx, al

    ; Read entry point from 0x7BFC (we wrote it there in vm.rs)
    mov dword ecx, [0x7BFC]

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

    ; Write 'B' to serial
    mov dx, 0x3F8
    mov al, 'B'
    out dx, al

    ; ecx contains the entry point previously read before entering protected mode
    ; just to be safe, we re-read it.
    mov ecx, dword [0x7BFC]
    
    ; Write 'C' to serial
    mov dx, 0x3F8
    mov al, 'C'
    out dx, al

    ; Jump to entry point
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
