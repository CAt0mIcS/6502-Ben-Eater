; ROM address range: 0x8000 - 0xffff
; RAM address range: 0x0200 - 0x3fff

; VIA addressing mode:
; PORTB = $6000         (used by LCD)
PORTA = $6001
; DDRB = $6002          (used by LCD)
DDRA = $6003

    .org $8000

reset:
    jsr lcd_setup

    ; Print the message
    ldy #0
message_print_loop:
    lda message,y
    beq halt
    jsr lcd_write_char
    iny
    jmp message_print_loop


halt:
    jmp halt

message: .asciiz "Hello, World!"

    .include "LCD.s"

    .org $fffc
    .word reset
    .word $0000