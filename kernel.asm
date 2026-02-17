[org 0x7e00]

jmp kernel_pre_init

  boot_device db 0
  text_color db 0
  back_color db 0
  current_page db 0
  os_input_string equ 0x7d00

  Program_Registers:
  dw 0
  program_register_a dw 0
  program_register_b dw 0
  program_register_c dw 0
  program_register_d dw 0
  program_register_e dw 0
  program_register_f dw 0
  program_register_i dw 0
  program_register_s dw 0
  program_flag_zero db 0
  program_flag_carry db 0
  program_flag_equal db 0
  register_a db 0
  register_b db 0

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

  call os_read_program

kernel_run_program:
  program_load_instruction:
    call program_load_byte
      cmp al, 0
      je program_load_instruction
      cmp al, 1
      je .program_instruction_add_RR
      cmp al, 2
      je .program_instruction_add_RV
      cmp al, 3
      je .program_instruction_mul_RR
      cmp al, 4
      je .program_instruction_mul_RV
      cmp al, 5
      je .program_instruction_div_RR
      cmp al, 6
      je .program_instruction_div_RV
      cmp al, 7
      je .program_instruction_shl_RR
      cmp al, 8
      je .program_instruction_shl_RV
      cmp al, 9
      je .program_instruction_shr_RR
      cmp al, 0ah
      je .program_instruction_shr_RV
      cmp al, 0bh
      je .program_instruction_not_R
      cmp al, 0ch
      je .program_instruction_test_RR
      cmp al, 0dh
      je .program_instruction_and_RR
      cmp al, 0eh
      je .program_instruction_and_RV
      cmp al, 0fh
      je .program_instruction_or_RR
      cmp al, 10h
      je .program_instruction_or_RV
      cmp al, 11h
      je .program_instruction_xor_RR
      cmp al, 12h
      je .program_instruction_xor_RV
      cmp al, 13h
      je .program_instruction_clc
      cmp al, 14h
      je .program_instruction_stc
      cmp al, 15h
      je .program_instruction_hlt
      cmp al, 16h
      je .program_instruction_ret
      cmp al, 17h
      je .program_instruction_push_R
      cmp al, 18h
      je .program_instruction_pop_R
      cmp al, 19h
      je .program_instruction_call_M
      cmp al, 1ah
      je .program_instruction_jc_M
      cmp al, 1bh
      je .program_instruction_jnc_M
      cmp al, 1ch
      je .program_instruction_jz_M
      cmp al, 1dh
      je .program_instruction_jnz_M
      cmp al, 1eh
      je .program_instruction_jmp_eq_M
      cmp al, 1fh
      je .program_instruction_jmp_l_M
      cmp al, 20h
      je .program_instruction_jmp_g_M
      cmp al, 21h
      je .program_instruction_jmp_le_M
      cmp al, 22h
      je .program_instruction_jmp_ge_M
      cmp al, 23h
      je .program_instruction_jmp_ne_M
      cmp al, 2ch
      je .program_instruction_jmp_M
      cmp al, 24h
      je .program_instruction_mov_RR
      cmp al, 25h
      je .program_instruction_mov_RM
      cmp al, 26h
      je .program_instruction_mov_RV
      cmp al, 27h
      je .program_instruction_mov_MR
      cmp al, 28h
      je .program_instruction_cmp_RR
      cmp al, 29h
      je .program_instruction_cmp_RM
      cmp al, 2ah
      je .program_instruction_cmp_RV
      cmp al, 2bh
      je .program_instruction_int_X
      cmp al, 2dh
      je .program_instruction_lodb
      cmp al, 2eh
      je .program_instruction_lodw
      cmp al, 2fh
      je .program_instruction_stob
      cmp al, 30h
      je .program_instruction_stow
jmp kernel_run_program
  program_read_byte:
    mov si, 0B000h
    add si, byte [program_register_i]
    inc word [program_register_i]
    lodsb
    and ax, 255
    ret
  program_read_word:
    mov si, 0B000h
    add si, word [program_register_i]
    add word [program_register_i], 2
    lodsw
    and ax, 65535
    ret
  program_get_one_register:
    mov byte [register_a], ax
    mov si, Program_Registers
    add si, byte [register_a]
    lodsw
    ret
  program_get_two_registers:
    push ax
    shr ax, 4
    shl ax, 1
    mov byte [register_a], ax
    pop ax
    and ax, 15
    shl ax, 1
    mov byte [register_b], ax
    mov si, Program_Registers
    add si, byte [register_b]
    lodsw
    mov bx, ax
    mov si, Program_Registers
    add si, byte [register_a]
    lodsw
    ret
  program_get_register_and_value:
    mov bx, ax
    and bx, 15
    shr ax, 4
    shl ax, 1
    mov byte [register_a], ax
    mov si, Program_Registers
    add si, byte [register_a]
    lodsw
    ret
  program_set_one_register:
    mov di, Program_Registers
    add di, byte [register_a]
    stosw
    ret
  program_update_flags:
    jnz .no_zero
    mov byte [program_flag_zero], 1
    .no_zero:
    jnc .no_carry
    mov byte [program_flag_carry], 1
    .no_carry:
    ret
  program_push_register_a:
    call program_set_one_register
    push es
    push bx
    mov bx, 1000h
    mov es, bx
    mov di, word [program_register_s]
    stosw
    pop bx
    pop es
    add word [program_register_s], 2
    ret
  program_pop_register_a:
    call program_set_one_register
    push ds
    push bx
    mov bx, 1000h
    mov ds, bx
    mov si, word [program_register_s]
    lodsw
    pop bx
    pop ds
    sub word [program_register_s], 2
    ret
  .program_instruction_add_RR:
    call program_read_byte
    call program_get_two_registers
    add ax, bx
    call program_update_flags
    call program_set_one_register
    ret
  .program_instruction_add_RV:
    call program_read_byte
    call program_get_one_register
    mov bx, ax
    call program_read_word
    add ax, bx
    call program_update_flags
    call program_set_one_register
    ret
  .program_instruction_mul_RR:
    call program_read_byte
    call program_get_two_registers
    mul bx
    call program_update_flags
    call program_set_one_register
    ret
  .program_instruction_mul_RV:
    call program_read_byte
    call program_get_one_register
    mov bx, ax
    call program_read_word
    mul bx
    call program_update_flags
    call program_set_one_register
  .program_instruction_div_RR:
    call program_read_byte
    call program_get_two_registers
    div bx
    call program_update_flags
    call program_set_one_register
    ret
  .program_instruction_shl_RR:
    call program_read_byte
    call program_get_two_registers
    shl ax, bx
    call program_update_flags
    call program_set_one_register
    ret
  .program_instruction_shl_RV:
    call program_read_byte
    call program_get_register_and_value
    shl ax, bx
    call program_update_flags
    call program_set_one_register
    ret
  .program_instruction_shr_RR:
    call program_read_byte
    call program_get_two_registers
    shr ax, bx
    call program_update_flags
    call program_set_one_register
    ret
  .program_instruction_shr_RV:
    call program_read_byte
    call program_get_register_and_value
    shr ax, bx
    call program_update_flags
    call program_set_one_register
    ret
  .program_instruction_not_R:
    call program_read_byte
    call program_get_one_register
    not ax
    call program_update_flags
    call program_set_one_register
    ret
  .program_instruction_test_RR:
    call program_read_byte
    call program_get_two_registers
    test ax, bx
    call program_update_flags
    call program_set_one_register
    ret
  .program_instruction_and_RR:
    call program_read_byte
    call program_get_two_registers
    and ax, bx
    call program_update_flags
    call program_set_one_register
    ret
  .program_instruction_and_RV:
    call program_read_byte
    call program_get_one_register
    mov bx, ax
    call program_read_word
    and ax, bx
    call program_update_flags
    call program_set_one_register
    ret
  .program_instruction_or_RR:
    call program_read_byte
    call program_get_two_registers
    or ax, bx
    call program_update_flags
    call program_set_one_register
    ret
  .program_instruction_or_RV:
    call program_read_byte
    call program_get_one_register
    mov bx, ax
    call program_read_word
    or ax, bx
    call program_update_flags
    call program_set_one_register
    ret
  .program_instruction_xor_RR:
    call program_read_byte
    call program_get_two_registers
    xor ax, bx
    call program_update_flags
    call program_set_one_register
    ret
  .program_instruction_xor_RV:
    call program_read_byte
    call program_get_one_register
    mov bx, ax
    call program_read_word
    xor ax, bx
    call program_update_flags
    call program_set_one_register
    ret
  .program_instruction_clc:
    mov byte [program_flag_carry], 0
    ret
  .program_instruction_stc:
    mov byte [program_flag_carry], 1
    ret
  .program_instruction_hlt:
    jmp kernel_exit
  .program_instruction_ret:
    mov byte [register_a], 8 ; Set register to i
    call program_pop_register_a
    ret
  .program_instruction_push_R:
    call program_read_byte
    call program_get_one_register
    call program_push_register_a
    ret
  .program_instruction_pop_R:
    call program_read_byte
    call program_get_one_register
    call program_pop_register_a
    ret
  .program_instruction_call_M:
    call program_read_word
    mov word [program_register_i], ax
    ret
  .program_instruction_jc_M:
    call program_read_word
    cmp byte [program_flag_carry], 1
    jne .leave
    mov word [program_register_i], ax
    .leave:
    ret
  .program_instruction_jnc_M:
    call program_read_word
    cmp byte [program_flag_carry], 0
    jne .leave
    mov word [program_register_i], ax
    .leave:
    ret
  .program_instruction_jz_M:
    call program_read_word
    cmp byte [program_flag_zero], 1
    jne .leave
    mov word [program_register_i], ax
    .leave:
    ret
  .program_instruction_jnz_M:
    call program_read_word
    cmp byte [program_flag_zero], 0
    jne .leave
    mov word [program_register_i], ax
    .leave:
    ret
  .program_instruction_jmp_eq_M:
    call program_read_word
    cmp byte [program_flag_equal], 1
    jne .leave
    mov word [program_register_i], ax
    .leave:
    ret
  .program_instruction_jmp_l_M:
    ret
  .program_instruction_jmp_g_M:
    ret
  .program_instruction_jmp_le_M:
    ret
  .program_instruction_jmp_ge_M:
    ret
  .program_instruction_jmp_ne_M:
    call program_read_word
    cmp byte [program_flag_equal], 0
    jne .leave
    mov word [program_register_i], ax
    .leave:
    ret
  .program_instruction_jmp_M:
    call program_read_word
    mov word [program_register_i], ax
    ret
  .program_instruction_mov_RR:
    call program_read_byte
    call program_get_two_registers
    mov ax, bx
    call program_set_one_register
    ret
  .program_instruction_mov_RM:
    call program_read_byte
    call program_get_one_register
    call program_read_word
    mov si, ax
    add si, program_loading_point
    lodsw
    call program_set_one_register
    ret
  .program_instruction_mov_RV:
    call program_read_byte
    call program_get_one_register
    call program_read_word
    call program_set_one_register
    ret
  .program_instruction_mov_MR:
    call program_read_byte
    call program_get_one_register
    push ax
    call program_read_word
    mov di, ax
    add di, program_loading_point
    pop ax
    stosw
    ret
  .program_instruction_cmp_RR:
    call program_read_byte
    call program_get_two_registers
    cmp ax, bx
    call program_update_flags
    ret
  .program_instruction_cmp_RM:
    call program_read_byte
    call program_get_one_register
    mov bx, ax
    call program_read_word
    mov si, ax
    add si, program_loading_point
    lodsw
    cmp ax, bx
    call program_update_flags
    ret
  .program_instruction_cmp_RV:
    call program_read_byte
    call program_get_one_register
    mov bx, ax
    call program_read_word
    cmp bx, ax
    call program_update_flags
    ret
  .program_instruction_int_X:
    call program_read_byte
    call program_execute_interrupt
    ret
  .program_instruction_lodb:
    mov si, word [program_register_e]
    inc word [program_register_e]
    add si, program_loading_point
    lodsb
    mov word [register_a], 1
    call program_set_one_register
    ret
  .program_instruction_lodw:
    mov si, word [program_register_e]
    inc word [program_register_e]
    inc word [program_register_e]
    add si, program_loading_point
    lodsw
    mov word [register_a], 1
    call program_set_one_register
    ret
  .program_instruction_stob:
    mov di, word [program_register_f]
    inc word [program_register_f]
    add di, program_loading_point
    mov ax, word [program_register_a]
    stosb
    ret
  .program_instruction_stow:
    mov di, word [program_register_f]
    inc word [program_register_f]
    inc word [program_register_f]
    add di, program_loading_point
    mov ax, word [program_register_a]
    stosw
    ret

kernel_exit:
os_shutdown: ; Copied from Internet

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
  jmp kernel_pre_init

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

os_read_program:
  pusha
  mov ah, 2
  mov al, 32
  mov ch, 0
  mov cl, 17
  mov dh, 0
  mov dl, byte [boot_drive]
  xor bx, bx
  mov es, bx
  mov bx, 0B000h
  popa
  ret

times 0E00h - ($-$$) - 3 db 0
db "EOK"

program_loading_point:
