; ---- Clear screen (blue background, white text) ----
mov b, 0x1F
int 1

; ---- Ask for first number ----
mov e, msg1
int 4

mov f, buf1
int 5              ; input string

mov f, buf1
int 6              ; convert string -> integer
mov b, a           ; store first number in b

; ---- Ask for second number ----
mov e, msg2
int 4

mov f, buf2
int 5

mov f, buf2
int 6
add a, b           ; a = first + second

; ---- Print result ----
mov e, msg3
int 4

mov e, outbuf
int 7              ; convert integer to string
int 4              ; print result

hlt

; ---- Data Section ----
msg1:
data "Enter first number: "
data 0
msg2:
data "Enter second number: "
data 0
msg3:
data "Result = "
data 0

buf1:
data 0,0,0,0,0,0
buf2:
data 0,0,0,0,0,0
outbuf:
data 0,0,0,0,0,0,0
