[org 0x7e00]

jmp kernel_pre_init

%include "calls_map.asm"

boot_device db 0
text_color db 0
back_color db 0
current_page db 0
os_input_string equ 0x7d00

kernel_pre_init:
mov byte [boot_device], bl ; Save boot device
; Clean all registers
xor ax, ax
xor bx, bx
mov cx, 1 ; for os_char_out
xor dx, dx

kernel_init:
; Set Colors : White text on Green
mov byte [text_color], 15
mov byte [back_color], 0
; Set Page Number
mov byte [current_page], 0

call os_clear_screen ; Clear the screen
call os_move_cursor_to_start ; Move the cursor to start position

mov si, welcome_msg
call os_string_out

kernel_loop:
call os_move_cursor_to_newline
mov si, cli_msg
call os_string_out
call os_string_in
mov si, os_input_string
  mov di, command_clear
    call os_string_compare_till_b_length
    jc kernel_clear
  mov di, command_echo
    call os_string_compare_till_b_length
    jc kernel_echo
  mov di, command_ls
    call os_string_compare_till_b_length
    jc kernel_ls
  mov di, command_read
    call os_string_compare_till_b_length
    jc kernel_read
  mov di, command_write
    call os_string_compare_till_b_length
    jc kernel_write
  mov di, command_touch
    call os_string_compare_till_b_length
    jc kernel_touch
  mov di, command_help
    call os_string_compare_till_b_length
    jc kernel_help
  mov di, command_shutdown
    call os_string_compare_till_b_length
    jc kernel_shutdown
  mov di, command_counter
    call os_string_compare_till_b_length
    jc kernel_counter

jmp kernel_loop

welcome_msg db "Hello! Welcome to AIOS 3!", 13, 0
cli_msg db "> ", 0
new_file_name db "new_demo_file.txt", 0
command_clear db "clear", 0
command_echo db "echo", 0
command_ls db "ls", 0
command_read db "read", 0
command_write db "write", 0
command_touch db "touch", 0
command_help db "help", 0
command_shutdown db "shutdown", 0
command_counter db "counter", 0

kernel_clear:
  call os_clear_screen
  call os_move_cursor_to_start
  jmp kernel_loop

kernel_echo:
  mov si, os_input_string
  add si, 5
  call os_string_out
  jmp kernel_loop

kernel_ls:
  call os_print_files_index
  jmp kernel_loop

kernel_read:
  add si, 5
  mov word [.file_name], si ; Copy File Name Pointer to .file_name
  mov dx, 0
  mov di, word [.file_name]
  mov bx, 1000h
  mov es, bx
  mov bx, 0100h
  call os_read_file
  jnc .failed
  .done:
    mov dx, 0
    mov es, dx
    mov bx, 1000h
    mov ds, bx
    mov si, 0100h
    call os_string_out
    xor bx, bx
    mov ds, bx
    jmp kernel_loop
  .failed:
    mov bx, 0
    mov es, bx
    mov ds, bx
    mov dx, 0
    mov si, .failure_msg
    call os_string_out
    jmp kernel_loop
  .file_name dw 0
  .failure_msg db "File not found!", 0

kernel_write:
  add si, 6
  mov word [.file_name], si ; Copy File Name Pointer to .file_name
  call os_string_in
  mov si, os_input_string
  call os_string_length
  mov word [.file_size], cx
  mov bx, 1000h
  mov es, bx
  mov di, 0100h
  call os_string_copy ; Copy File Contents to 1:0100h
  mov dx, 0
  mov di, word [.file_name]
  mov cx, word [.file_size]
  mov bx, 1000h
  mov es, bx
  mov bx, 0100h
  call os_write_file
  jnc .failed
  .done:
    mov dx, 0
    mov es, dx
    mov ds, dx
    jmp kernel_loop
  .failed:
    mov dx, 0
    mov es, dx
    mov ds, dx
    mov si, .failure_msg
    call os_string_out
    jmp kernel_loop
  .file_name dw 0
  .file_size dw 0
  .failure_msg db "File not found!", 0

kernel_touch:
  mov si, os_input_string
  add si, 6
  call os_new_file
  jmp kernel_loop

kernel_help:
  mov si, kernel_help_string
  call os_string_out
  jmp kernel_loop
  kernel_help_string db "This is AIOS 3!", 13, "Commands:", 13, "    clear", 13, "    echo", 13, "    ls", 13, "    write", 13, "    touch", 13, "    help", 13, "    shutdown", 13, "    counter", 0

kernel_shutdown:
  call os_shutdown
  jmp kernel_loop

kernel_counter:
  xor cx, cx
  mov ax, word [.count]
  mov si, .kernel_counter_msg
  clc
  .continue:
    inc cx
    cmp cx, 4096
    je .print
    mov ah, 1
    int 16h
    jnz .exit
    jmp .continue
  .print:
    inc word [.count]
    mov ax, word [.count]
    call os_int_to_string
    call os_string_out
    call os_move_cursor_to_line_start
    xor cx, cx
    jmp .continue
  .exit:
    mov ah, 0
    int 16h
    jmp kernel_loop
  .kernel_counter_msg db "Meow", 13, 0
  .count dw 0

os_shutdown: ; Internet

; Check for APM
mov ax, 5300h
xor bx, bx
int 15h
jc no_apm        ; carry set = no APM

; Connect to APM
mov ax, 5301h
xor bx, bx
int 15h
jc no_apm

; Set power state to OFF
mov ax, 5307h
mov bx, 0001h    ; all devices
mov cx, 0003h    ; power off
int 15h

no_apm:
; fallback here (halt, reboot, etc.)

os_clear_screen:
  push ax
  push bx
  push cx
  push dx

  mov ah, 6
  mov al, 0

  mov bh, [back_color]
  shl bh, 4
  or bh, [text_color]

  mov ch, 0
  mov cl, 0
  mov dh, 24
  mov dl, 79
  int 10h

  pop dx
  pop cx
  pop bx
  pop ax
  ret

os_move_cursor:
  push ax
  push bx
  push dx

  mov ah, 2
  int 10h

  pop dx
  pop bx
  pop ax
  ret

os_move_cursor_to_start:
  push ax
  push bx
  push dx

  mov ah, 2
  mov bh, [current_page]
  mov dh, 0
  mov dl, 0
  int 10h

  pop dx
  pop bx
  pop ax
  ret

os_move_cursor_to_newline:
  push ax
  push bx
  push cx
  push dx

  mov ah, 3
  mov bh, [current_page]
  int 10h
  mov ah, 2
  inc dh
  cmp dh, 25
  jl .skipDH
  dec dh
  call os_page_down
  .skipDH:
  mov dl, 0
  int 10h

  pop dx
  pop cx
  pop bx
  pop ax
  ret

os_move_cursor_to_line_start:
  push ax
  push bx
  push cx
  push dx

  mov ah, 3
  mov bh, [current_page]
  int 10h
  mov ah, 2
  mov dl, 0
  int 10h

  pop dx
  pop cx
  pop bx
  pop ax
  ret

os_char_in:
  push ax
  
  mov ah, 0
  int 16h
  mov byte [.key], al
  pop ax
  mov al, [.key]
  ret
  .key db 0

os_char_out:
  push ax
  push bx
  
  mov ah, 9
  mov bh, [current_page]
  mov bl, [back_color]
  shl bl, 4
  or bl, [text_color]
  int 10h
  
  pop bx
  pop ax
  ret

os_increment_cursor:
  push ax
  push bx
  push cx
  push dx
  
  mov ah, 3
  mov bh, [current_page]
  int 10h
  inc dl
  cmp dl, 80
  jl .skipDL
  sub dl, 80
  inc dh
  cmp dh, 25
  jl .skipDH
  call os_page_down
  dec dh
  .skipDH:
  .skipDL:
    mov ah, 2
    int 10h

  pop dx
  pop cx
  pop bx
  pop ax
  ret

os_decrement_cursor:
  push ax
  push bx
  push cx
  push dx

  mov ah, 3
  mov bh, [current_page]
  int 10h
  test dl, dl
  jz .skip
  dec dl
  mov ah, 2
  int 10h
  .skip:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

os_page_down:
  push ax
  push bx
  push cx
  push dx

  mov ah, 6
  mov al, 1
  mov bh, [back_color]
  shl bh, 4
  or bh, [text_color]
  mov cx, 0
  mov dh, 24
  mov dl, 79
  int 10h

  pop dx
  pop cx
  pop bx
  pop ax
  ret

os_string_out:
  push ax
  push bx
  push cx
  push dx
  push si

  mov bh, [current_page]
  mov bl, [back_color]
  shl bl, 4
  or bl, [text_color]
  mov cx, 1
  .continue:
    lodsb
    cmp al, 0
    je .done
    cmp al, 13
    je .enter
    mov ah, 9
    int 10h
    call os_increment_cursor
    jmp .continue
  .enter:
    call os_move_cursor_to_newline
    jmp .continue
  .done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

os_string_in:
  push ax
  push bx
  push cx
  push dx
  push di

  mov di, os_input_string
  mov bh, [current_page]
  mov bl, [back_color]
  shl bl, 4
  or bl, [text_color]
  mov cx, 1
  .continue:
    mov ah, 0
    int 16h
    cmp al, 8 ; Backspace
    je .backspace
    cmp al, 13 ; Enter
    je .enter
    cmp al, 32 ; Space, First Keyboard Character
    jl .continue
    cmp al, 126 ; Last Keyboard Character
    jg .continue
    stosb
    mov ah, 9
    int 10h
    call os_increment_cursor
    jmp .continue
  .backspace:
    cmp di, os_input_string
    jle .continue
    mov byte [di], 0
    dec di
    call os_decrement_cursor
    mov ah, 9
    mov al, 32
    int 10h
    jmp .continue
  .enter:
    mov byte [di], 0
    call os_move_cursor_to_newline
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

os_string_length:
  push ax
  push si
  xor cx, cx
  .continue:
    inc cx
    lodsb
    cmp al, 0
    je .done
    jmp .continue
  .done:
    pop si
    pop ax
    ret

os_string_copy:
  push ax
  push si
  push di
  
  .continue:
    lodsb
    stosb
    cmp al, 0
    je .done
    jmp .continue
  .done:
    pop di
    pop si
    pop ax
    ret

os_string_compare:
  push ax
  push si
  push di

  .continue:
    lodsb
    cmp al, byte [di]
    jne .unequal
    cmp al, 0
    je .equal
    cmp byte [di], 0
    je .equal
    inc di
    jmp .continue
  .equal:
    stc
    jmp .done
  .unequal:
    clc
  .done:
    pop di
    pop si
    pop ax
    ret

os_string_compare_till_b_length:
  push ax
  push si
  push di

  .continue:
    lodsb
    cmp byte [di], 0
    je .equal
    cmp al, byte [di]
    jne .unequal
    inc di
    jmp .continue
  .equal:
    stc
    jmp .done
  .unequal:
    clc
  .done:
    pop di
    pop si
    pop ax
    ret

os_string_to_int:
  push cx
  push si

  xor ax, ax
  mov ch, 10
  .continue:
    mov cl, byte [si]
    cmp cl, 0
    je .done
    sub cl, '0'
    mul ch
    add al, cl
    jmp .continue
  .done:
    pop si
    pop cx
    ret

os_int_to_string:
  push ax
  push bx
  push cx
  push dx

  mov si, .string
  push si
  mov bx, 10
  xor cx, cx
  .push:
    mov dx, 0
    div bx
    push dx
    inc cx
    cmp ax, 0
    jnz .push
  .pop:
    pop dx
    add dl, '0'
    mov byte [si], dl
    inc si
    dec cx
    jnz .pop
  mov byte [si], 0
  pop si
  pop dx
  pop cx
  pop bx
  pop ax
  ret
  .string times 7 db 0

%include "fs.asm"

times 0E00h - ($-$$) - 3 db 0
db "EOK"
