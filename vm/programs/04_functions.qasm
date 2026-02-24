main:
  mov a, 7
  call double
  mov e, t
  int 7
  int 4
  hlt
double:
  add a, a
  ret
t:
