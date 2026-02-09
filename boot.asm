[org 0x7c00]
xor ax, ax
mov ds, ax
cld

mov ah, 2h
mov al, 8
mov ch, 0
mov cl, 2
mov dh, 0
xor bx, bx
mov es, bx
mov bx, 0x7e00
int 13h
jmp 0x7e00

times 510-($-$$) db 0
dw 0xAA55
