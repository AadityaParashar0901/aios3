mov a, 5
mov b, 1

loop:
  cmp a, 1
  jmp le done
  mul b, a
  add a, 65535
  jmp loop
done:
  mov a, b
  mov e, t
  int 7
  int 4
  hlt
t:
