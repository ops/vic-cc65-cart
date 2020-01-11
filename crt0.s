;
; Startup code for crt with cc65
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

        .import         initlib, donelib
        .import         zerobss, copydata, push0
        .import         callmain
        .import         __STACKSIZE__                   ; Linker generated
        .import         __RAM_START__, __RAM_SIZE__     ; Linker generated
        .importzp       ST

        .include        "zeropage.inc"


; ------------------------------------------------------------------------

.segment        "LOADADDR"
        .export __LOADADDR__: absolute = 1
        .addr   *+2

.segment        "STARTUP"

; Startup code

        .word   reset
        .word   $FEA9

        ; Cart signature
        .byte   $41,$30,"CBM"

reset:

        JSR     INITMEM                 ; initialise and test RAM
        JSR     FRESTOR                 ; restore default I/O vectors
        JSR     INITVIA                 ; initialise I/O registers
        JSR     INITSK                  ; initialise hardware

        JSR     INITVCTRS               ; initialise BASIC vector table
        JSR     INITBA                  ; initialise BASIC RAM locations
        JSR     FREMSG                  ; print start up message and initialise memory pointers
        CLI                             ; enable interrupts

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
