# vic-cc65-cart
Simple stub for VIC-20 cart image created with
[cc65](https://cc65.github.io/) compiler suite.

Compile:

       cl65 -t vic20 -C cart.cfg -o cart.prg cart.c crt0.s

If you want to add 2-byte load address to cart image add
option `-u __LOADADDR__` to compile command.

Test with VICE:

       xvic -cartA cart.prg
