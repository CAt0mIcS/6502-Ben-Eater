PORTA = $6000
PORTB = $6001
DDRA = $6002
DDRB = $6003

    .org $8000

reset:
    ; Set Data Direction Register B to output
    lda #$ff
    sta DDRA

lcd:
    ; LCD bit sequence:
    ; X-X-E-RS-D7/D3-D6/D2-D5/D1-D4/D0

    ; Set LCD function set to 4-bit data mode with 2 display lines and 5x8 dots format display mode
    ; In 4-bit mode, first the 4 higher order bits are sent and then the 4 lower order bits.
    ; The enable pin is pulsed HIGH after the higher order bits are set and pulsed low again before the lower order bits are set. Then pulsed HIGH/LOW again to latch lower order bits 
    lda #%00100010
    sta PORTA

    lda #%00000010
    sta PORTA

    

    lda #%00100010
    sta PORTA

    lda #%00000010
    sta PORTA
    

    lda #%00101000
    sta PORTA

    lda #%00001000
    sta PORTA

    ; Turn on LCD display and cursor
    lda #%00100000
    sta PORTA

    lda #%00000000
    sta PORTA


    lda #%00101111
    sta PORTA

    lda #%00001111
    sta PORTA

    ; Set LCD entry mode
    lda #%00100000
    sta PORTA

    lda #%00000000
    sta PORTA


    lda #%00100110
    sta PORTA

    lda #%00000110
    sta PORTA

    ; Clear display
    lda #%00100000
    sta PORTA

    lda #%00000000
    sta PORTA


    lda #%00100001
    sta PORTA

    lda #%00000001
    sta PORTA

infinite_wait:
    ; Write character H
    lda #%00110100
    sta PORTA

    lda #%00010100
    sta PORTA


    lda #%00111000
    sta PORTA

    lda #%00011000
    sta PORTA


    nop
    jmp infinite_wait

    .org $fffc
    .word reset
    .word $0000