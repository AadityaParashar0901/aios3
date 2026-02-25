; =========================
; CODE SECTION
; =========================

start:

    mov F, inputStr
    int 5

    mov B, F          ; left pointer
    mov C, F          ; temp pointer

; -------- FIND END --------
find_end:
    mov A, [C]
    and A, 255
    cmp A, 0
    jz end_found
    cmp A, 13
    jz end_found
    inc C
    jmp find_end

end_found:
    dec C             ; C = last valid char


; -------- CHECK LOOP --------
check_loop:

    ; D = C
    mov D, C
    sub D, B          ; D = C - B

    cmp D, 0
    jz is_pal         ; crossed exactly
    jmp l is_pal      ; crossed

    mov A, [B]
    and A, 255
    mov D, [C]
    and D, 255
    cmp A, D
    jnz not_pal

    inc B
    dec C
    jmp check_loop


; -------- SUCCESS --------
is_pal:
    mov E, msgPal
    int 4
    hlt


; -------- FAIL --------
not_pal:
    mov E, msgNot
    int 4
    hlt



; =========================
; DATA SECTION
; =========================

inputStr:
data "                "
data 0

msgPal:
data "Palindrome"
data 13
data 0

msgNot:
data "Not Palindrome"
data 13
data 0
