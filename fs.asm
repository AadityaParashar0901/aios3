%if 0

Offset 00 - 01: Bootloader -> 1 Sector
Offset 02 - 0F: Kernel -> 7 Sectors
Offset 10 - 1F: File Table -> 64 Files -> 8 Sectors
Offset 20: File Data (17th Sector) {
  Offset 20 - 3F: File 01 Data
  Offset 40 - 5F: File 02 Data
  ...
}
Each file will be of 8 KB -> 16 Sectors
File Table Entry (64 bytes):
  File Exists Byte (1 byte)
  Identifier (61 bytes) ; Name
  Size (2 bytes)

%endif

total_files equ 64
file_data_start_sector equ 17

os_read_files_index:
  pusha

  mov ah, 2
  mov al, 8
  mov ch, 0
  mov cl, 9
  mov dh, 0
  xor bx, bx
  mov es, bx
  mov bx, 0A000h
  int 13h

  popa
  ret

os_write_files_index:
  pusha

  mov ah, 3
  mov al, 8
  mov ch, 0
  mov cl, 9
  mov dh, 0
  xor bx, bx
  mov es, bx
  mov bx, 0A000h
  int 13h

  popa
  ret

os_print_files_index:
  pusha

  call os_read_files_index
  
  xor bx, bx
  mov ds, bx
  mov si, 0A000h
  xor cx, cx
  .continue:
    lodsb
    cmp al, 0
    je .skip ; If we don't have a file entry here, skip
    call os_string_out
    call os_move_cursor_to_newline
  .skip:
    add si, 63 ; Skip the File
    inc cx
    cmp cx, total_files ; Wait for total files
    je .done
    jmp .continue
  .done:
    popa
    ret

os_find_file: ; (es:di file_name) -> (cx file_id, dx file_size, carry-flag if successful)
  pusha
  call os_read_files_index
  xor bx, bx
  mov ds, bx
  mov si, 0A000h
  xor cx, cx
  .continue:
    lodsb
    cmp al, 0
    je .skip
    call os_string_compare
    jc .found
  .skip:
    add si, 63
    inc cx
    cmp cx, total_files
    je .not_found
    jmp .continue
  .found:
    mov word [.file_id], cx
    add si, 61
    mov ax, word [si]
    mov word [.file_size], ax
    stc
    popa
    mov cx, word [.file_id]
    mov dx, word [.file_size]
    ret
  .not_found:
    clc
    popa
    ret
  .file_id dw 0
  .file_size dw 0

os_new_file:
  call os_read_files_index
  pusha

  push si ; Store New File Name

  xor bx, bx
  mov ds, bx
  mov si, 0A000h

  .find_empty_file_entry:
    lodsb
    cmp al, 0
    je .found_empty_file_entry
    add si, 63
    jmp .find_empty_file_entry
  .found_empty_file_entry:
    mov di, si
    dec di

    mov al, 1
    stosb

    pop si
    call os_string_copy

    call os_write_files_index
    popa
    ret

os_read_file: ; (dx:di file_name, es:bx memory_offset) -> (cx file_size, carry-flag if successful)
  pusha
  push bx
  push es
  mov es, dx
  call os_find_file
  jnc .not_found
  .found:
    mov word [.file_size], dx
    shl cx, 4
    add cx, file_data_start_sector
    mov byte [.file_offset], cl
    mov ah, 2
    mov al, 16
    mov ch, 0
    mov cl, byte [.file_offset]
    mov dh, 0
    pop es
    pop bx
    int 13h
    stc
    popa
    mov cx, word [.file_size]
    ret
  .not_found:
    pop es
    pop bx
    clc
    popa
    ret
  .file_offset db 0
  .file_size dw 0

os_write_file: ; (cx file_size, dx:di file_name, es:bx memory_offset) -> carry-flag if successful
  pusha
  push bx
  push es
  ; push cx
  mov es, dx
  call os_find_file
  jnc .not_found
  .found:
    shl cx, 4 ; calculate file position in disk
    add cx, file_data_start_sector
    mov byte [.file_offset], cl
    mov ah, 3
    mov al, 16
    mov ch, 0
    mov cl, byte [.file_offset]
    mov dh, 0
    pop es
    pop bx
    int 13h
    popa
    stc
    ret
  .not_found:
    ; pop cx
    pop es
    pop bx
    popa
    clc
    ret
  .file_offset db 0
