; ROM address range: 0x8000 - 0xffff
; RAM address range: 0x0000 - 0x3fff

; VIA addressing mode:
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

LCD_E_BIT =      %00100000
LCD_NOT_E_BIT =  LCD_E_BIT ^ $ff
LCD_RS_BIT =     %00010000
LCD_NOT_RS_BIT = LCD_RS_BIT ^ $ff
LCD_READ_BIT = %01000000

    .org $8000

reset:
    ; Set PortB (LCD) to output
    lda #%11111111
    sta DDRB

lcd:
    ; LCD bit sequence:
    ; X-RW-E-RS-D7/D3-D6/D2-D5/D1-D4/D0

    ; Set LCD function set to 4-bit data mode with 2 display lines and 5x8 dots format display mode (0b0010-1000)
    ; In 4-bit mode, first the 4 higher order bits are sent and then the 4 lower order bits.
    ; The enable pin is pulsed HIGH after the higher order bits are set and pulsed low again before the lower order bits are set. Then pulsed HIGH/LOW again to latch lower order bits 
    
    ; First send one 8-bit sequence (only 4 higher-order bits will be received) which will set the LCD to 4-bit mode
    lda #%00100010
    sta PORTB

    lda #%00000010
    sta PORTB

    ; Send the actual command to display 2 lines with 5x8 dots format in 4-bit mode (0b0010-1000)
    lda #%00101000
    jsr lcd_write_instruction

    ; Turn on LCD display and cursor (0b0000-1111)
    lda #%00001111
    jsr lcd_write_instruction

    ; Set LCD entry mode (0b0000-0110)
    lda #%00000110
    jsr lcd_write_instruction

loop:
    ; Clear display (0b0000-0001)
    lda #%00000001
    jsr lcd_write_instruction

    lda #"H"
    jsr lcd_write_char
    lda #"e"
    jsr lcd_write_char
    lda #"l"
    jsr lcd_write_char
    lda #"l"
    jsr lcd_write_char
    lda #"o"
    jsr lcd_write_char
    lda #" "
    jsr lcd_write_char
    lda #"W"
    jsr lcd_write_char
    lda #"o"
    jsr lcd_write_char
    lda #"r"
    jsr lcd_write_char
    lda #"l"
    jsr lcd_write_char
    lda #"d"
    jsr lcd_write_char

    jmp loop

lcd_wait_busy:
    lda #%11110000 ; Set higher-order bits of register B to output, the rest to input
    sta DDRB

    lda #LCD_READ_BIT
    sta PORTB

lcd_wait_busy_internal:
    lda #(LCD_READ_BIT | LCD_E_BIT)
    sta PORTB
    ; nop ; 300ns hold

    lda PORTB ; Here we should be loading the busy bit + 0x60
    tax

    lda #LCD_READ_BIT
    sta PORTB

    ; We need to pulse E_BIT again due to the 4-bit operation mode
    lda #(LCD_READ_BIT | LCD_E_BIT)
    sta PORTB
    ; nop ; 300ns hold

    lda #LCD_READ_BIT
    sta PORTB

    txa
    and #%00001000 ; Pick out the busy pin, which sets the zero flag register
    bne lcd_wait_busy_internal

    lda #%11111111 ; Set register B back to output
    sta DDRB
    rts

lcd_write_instruction:
    tax
    ; lda (LCD_E_BIT | higher order bits)
    and #%11110000
    lsr
    lsr
    lsr
    lsr
    ora #LCD_E_BIT
    sta PORTB

    ; remove LCD_E_BIT from a register
    and #LCD_NOT_E_BIT
    ; lda higher order bits
    sta PORTB

    txa
    ; lda (LCD_E_BIT | lower order bits)
    and #%00001111
    ora #LCD_E_BIT
    sta PORTB

    ; remove LCD_E_BIT from a register
    and #LCD_NOT_E_BIT
    ; lda lower order bits
    sta PORTB

    jsr lcd_wait_busy
    rts

lcd_write_char:
    tax
    ; lda (LCD_E_BIT | LCD_RS_BIT | higher order bits)
    and #%11110000
    lsr
    lsr
    lsr
    lsr
    ora #(LCD_E_BIT | LCD_RS_BIT)
    sta PORTB

    ; remove LCD_E_BIT and LCD_RS_BIT from a register
    and #(LCD_NOT_E_BIT & LCD_NOT_RS_BIT)
    ; lda higher order bits
    sta PORTB

    txa
    ; lda (LCD_E_BIT | LCD_RS_BIT | lower order bits)
    and #%00001111
    ora #(LCD_E_BIT | LCD_RS_BIT)
    sta PORTB

    ; remove LCD_E_BIT and LCD_RS_BIT from a register
    and #(LCD_NOT_E_BIT & LCD_NOT_RS_BIT)
    ; lda lower order bits
    sta PORTB

    rts


    .org $fffc
    .word reset
    .word $0000