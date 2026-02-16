mov a, 3
mov b, 5
add a, b
add a, 48
mov e, heap_memory
mov f, e
stob ; [f++] <- (byte) a
int 2
hlt
heap_memory:
