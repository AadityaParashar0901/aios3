%if 0

Sector 01 - 01: Bootloader
Sector 02 - 09: Kernel
Sector 0A - 0F: File Table

File Table Entry (64 bytes):
  File Exists Byte (1 byte)
  Identifier (57 bytes) ; Name
  Attribute (1 byte):
    'D' - Directory
    'S' - System File
    'P' - Page File
    'F' - File
  Size (2 bytes)
  Pointer (3 bytes)

%endif

os_read_files_index:
  pusha
  
  mov si, .info_text
  call os_string_out

  mov ah, 2
  mov al, 6 ; 32
  mov ch, 0
  mov cl, 10
  mov dh, 0
  xor bx, bx ; mov bx, 1
  mov es, bx
  mov bx, 9000h ; xor bx, bx
  int 13h

  popa
  ret
  .info_text db "read files index", 13, 0

os_write_files_index:
  pusha
  
  mov si, .info_text
  call os_string_out

  mov ah, 3
  mov al, 6 ; 32
  mov ch, 0
  mov cl, 10
  mov dh, 0
  xor bx, bx ; mov bx, 1
  mov es, bx
  mov bx, 9000h ; xor bx, bx
  int 13h

  popa
  ret
  .info_text db "write files index", 13, 0

os_print_files_index:
  pusha
  
  mov si, .info_text
  call os_string_out

  xor bx, bx ; mov bx, 1
  mov ds, bx
  mov si, 9000h ; 0
  xor cx, cx
  .continue:
    lodsb
    cmp al, 0
    je .skip
    call os_string_out
  .skip:
    add si, 63
    inc cx
    cmp cx, 10h
    je .done
    jmp .continue
  .done:
    popa
    ret
  .info_text db "print files index", 13, 0

os_new_file:
  call os_read_files_index
  pusha

  push si
  mov si, .info_text
  call os_string_out
  pop si

  push si ; Store New File Name

  xor bx, bx
  mov ds, bx
  mov si, 9000h

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
  .info_text db "new file", 13, 0

os_write_file:
  pusha
