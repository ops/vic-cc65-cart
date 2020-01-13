;
; VIC-20 cart image with CC65 compiler suite
; Startup code
;

INITMEM := $FD8D
FRESTOR := $FD52
INITVIA := $FDF9
INITSK  := $E518

INITVCTRS := $E45B
INITBA    := $E3A4
FREMSG    := $E404
READY     := $C474

        .export         _exit
        .export         __STARTUP__ : absolute = 1      ; Mark as startup

        .import         initlib, callmain, donelib
        .import         zerobss, copydata
        .import         __STACKSIZE__                   ; Linker generated
        .import         __RAM_START__, __RAM_SIZE__     ; Linker generated
        .importzp       ST

        .include        "zeropage.inc"

; ------------------------------------------------------------------------

.segment "LOADADDR"
        .export __LOADADDR__: absolute = 1
        .addr   *+2

.segment "STARTUP"

; Startup code

        .word   reset
        .word   $FEA9

        ; Cart signature
        .byte   $41,$30,"CBM"

reset:
        jsr     INITMEM                 ; initialise and test RAM
        jsr     FRESTOR                 ; restore default I/O vectors
        jsr     INITVIA                 ; initialise I/O registers
        jsr     INITSK                  ; initialise hardware

        jsr     INITVCTRS               ; initialise BASIC vector table
        jsr     INITBA                  ; initialise BASIC RAM locations
        jsr     FREMSG                  ; print start up message and initialise memory pointers
        cli                             ; enable interrupts

        jsr     copydata

; Clear the BSS data.

        jsr     zerobss

; Set up the stack.

        lda     #<(__RAM_START__ + __RAM_SIZE__)
        sta     sp
        lda     #>(__RAM_START__ + __RAM_SIZE__)
        sta     sp+1            ; Set argument stack ptr

; Call the module constructors.

        jsr     initlib

; Push the command-line arguments; and, call main().

        jsr     callmain

; Back from main() [this is also the exit() entry]. Run the module destructors.

_exit:  pha                     ; Save the return code on stack
        jsr     donelib

; Place the program return code into BASIC's status variable.

        pla
        sta     ST

; Back to BASIC.

        jmp     READY                   ; do "READY." warm start
