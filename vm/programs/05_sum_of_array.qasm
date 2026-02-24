mov e, array
mov c, 4
mov b, 0
loop:
  lodb
  add b, a
  add c, 65535
  jz done
  jmp loop
done:
  mov e, t
  mov a, b
  int 7
  int 4
  hlt
array:
  data 10
  data 20
  data 30
  data 40
t:
