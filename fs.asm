%if 0

Sector 01 - 01: Bootloader
Sector 02 - 09: Kernel
Sector 0A - 0F: File Table -> 48 Files
Each file will be of 8 KB -> 16 Sectors
File Table Entry (64 bytes):
  File Exists Byte (1 byte)
  Identifier (58 bytes) ; Name
  Size (2 bytes)
  Pointer (3 bytes)

%endif

os_read_files_index:
  pusha

  mov ah, 2
  mov al, 48
  mov ch, 0
  mov cl, 10
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
  mov al, 48
  mov ch, 0
  mov cl, 10
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
    cmp cx, 48 ; Wait for 48 Files
    je .done
    jmp .continue
  .done:
    popa
    ret

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

os_write_file:
  pusha
  popa
  ret
