mov b, 0x2F
int 1

mov e, ask
int 4

mov f, buffer
int 5

; find length
mov e, buffer
mov c, 0

len_loop:
    lodb
    cmp a, 0
    jz len_done
    add c, 1
    jmp len_loop

len_done:
    add e, 65535     ; move back to last char
    mov d, c
    shr d, 1         ; half length

    mov f, buffer    ; left pointer
    mov c, d

check_loop:
    cmp c, 0
    jmp eq yes

    lodb             ; left char in a
    push a

    mov a, 0
    lodw             ; (using word read just to advance if needed)
    pop b            ; left char

    cmp a, b
    jmp ne no

    add c, 65535
    jmp check_loop

yes:
    mov e, yesmsg
    int 4
    hlt

no:
    mov e, nomsg
    int 4
    hlt

ask:
data "Enter string: "
data 0
yesmsg:
data "Palindrome!"
data 0
nomsg:
data "Not Palindrome."
data 0
buffer:
data 0,0,0,0,0,0,0,0,0,0,0
