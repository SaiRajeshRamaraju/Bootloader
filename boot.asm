bits 16
org 0x7C00          ; BIOS loads the bootloader here in real mode

start:
    ; Set up segment registers
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00  ; Setup stack pointer near top of segment

    ; Clear the screen
    call clearscreen

    ; Move cursor to top-left (row 0, col 0)
    mov dx, 0x0000      ; DH = row, DL = col
    push dx
    call movecursor
    add sp, 2

    ; Print the message
    push msg
    call print
    add sp, 2

    ; Halt
    cli
    hlt

; Clears the screen using BIOS interrupt 10h, function 07h
clearscreen:
    push bp
    mov bp, sp
    pusha

    mov ah, 0x07        ; Scroll window
    mov al, 0x00        ; Clear entire screen
    mov bh, 0x07        ; Attribute: light gray on black
    mov cx, 0x0000      ; Upper-left corner
    mov dx, 0x184F      ; Lower-right (row 24, col 79)
    int 0x10            ; BIOS video interrupt

    popa
    mov sp, bp
    pop bp
    ret

; Moves the cursor to a specific position
; Argument: DX = (row << 8 | col)
movecursor:
    push bp
    mov bp, sp
    pusha

    mov dx, [bp+4]      ; Get argument (cursor pos)
    mov ah, 0x02        ; Set cursor position
    mov bh, 0x00        ; Page number 0
    int 0x10

    popa
    mov sp, bp
    pop bp
    ret

; Prints a null-terminated string at the current cursor position
; Argument: [bp+4] = pointer to string
print:
    push bp
    mov bp, sp
    pusha

    mov si, [bp+4]      ; Load string pointer
    mov ah, 0x0E        ; Teletype output

.print_loop:
    lodsb               ; Load next byte from DS:SI into AL
    or al, al
    jz .done            ; If null terminator, end
    int 0x10            ; BIOS teletype output
    jmp .print_loop

.done:
    popa
    mov sp, bp
    pop bp
    ret

; Message string
msg: db "Hello, assembly", 0

; Boot sector padding and signature
times 510 - ($ - $$) db 0
dw 0xAA55             ; Boot signature

