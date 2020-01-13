# vic-cc65-cart
Simple stub for VIC-20 cart image created with CC65 compiler suite

Compile:

       cl65 -C cart.cfg -o cart.bin cart.c crt0.s

Test with VICE:

       xvic -cartA cart.bin

