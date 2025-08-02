PORTB = $6000
DDRB = $6002

LCD_E_BIT =      %00100000
LCD_NOT_E_BIT =  LCD_E_BIT ^ $ff
LCD_RS_BIT =     %00010000
LCD_NOT_RS_BIT = LCD_RS_BIT ^ $ff
LCD_READ_BIT = %01000000

lcd_setup:
    ; Set PortB (LCD) to output
    lda #%11111111
    sta DDRB

    ; LCD bit sequence:
    ; X-RW-E-RS-D7/D3-D6/D2-D5/D1-D4/D0

    ; Set LCD function set to 4-bit data mode with 2 display lines and 5x8 dots format display mode (0b0010-1000)
    ; In 4-bit mode, first the 4 higher order bits are sent and then the 4 lower order bits.
    ; The enable pin is pulsed HIGH after the higher order bits are set and pulsed low again before the lower order bits are set. Then pulsed HIGH/LOW again to latch lower order bits 

    ; Reset display to 8-bit mode by sending the higher nibble three times. This is required if we reset the 6502 multiple times without powering it off, as the LCD retains its settings
    ldy #3
lcd_init4:
    jsr lcd_wait_busy
    
    lda #(LCD_E_BIT | %00000011)
    sta PORTB

    ; Remove LCD_E_BIT
    and #LCD_NOT_E_BIT
    sta PORTB
    
    dey
    bne lcd_init4

    ; Send nibble to turn on 4-bit mode again
    jsr lcd_wait_busy
    lda #(LCD_E_BIT | %00000010)
    sta PORTB

    and #LCD_NOT_E_BIT
    sta PORTB
    ; From here on, the LCD is in 4-bit mode

    ; Send the actual command to display 2 lines with 5x8 dots format in 4-bit mode (0b0010-1000)
    lda #%00101000
    jsr lcd_write_instruction

    ; Turn on LCD display and cursor (0b0000-1111)
    lda #%00001111
    jsr lcd_write_instruction

    ; Set LCD entry mode (0b0000-0110)
    lda #%00000110
    jsr lcd_write_instruction

    ; Clear display (0b0000-0001)
    lda #%00000001
    jsr lcd_write_instruction

    jsr lcd_setup_delay
    rts

lcd_wait_busy:
    pha
    lda #%11110000 ; Set higher-order bits of register B to output, the rest to input
    sta DDRB
    nop

    lda #LCD_READ_BIT
    sta PORTB
    nop

lcd_wait_busy_internal:
    lda #(LCD_READ_BIT | LCD_E_BIT)
    sta PORTB
    nop

    lda PORTB ; Here we should be loading the busy bit + 0x60
    tax

    lda #LCD_READ_BIT
    sta PORTB
    nop

    ; We need to pulse E_BIT again due to the 4-bit operation mode
    lda #(LCD_READ_BIT | LCD_E_BIT)
    sta PORTB
    nop

    lda #LCD_READ_BIT
    sta PORTB

    txa
    and #%00001000 ; Pick out the busy pin, which sets the zero flag register
    bne lcd_wait_busy_internal

    lda #%11111111 ; Set register B back to output
    sta DDRB
    nop

    pla
    rts

lcd_write_instruction:
    jsr lcd_wait_busy

    tax
    ; lda (LCD_E_BIT | higher order bits)
    and #%11110000
    lsr
    lsr
    lsr
    lsr
    ora #LCD_E_BIT
    sta PORTB
    nop

    ; remove LCD_E_BIT from a register
    and #LCD_NOT_E_BIT
    ; lda higher order bits
    sta PORTB

    txa
    ; lda (LCD_E_BIT | lower order bits)
    and #%00001111
    ora #LCD_E_BIT
    sta PORTB
    nop

    ; remove LCD_E_BIT from a register
    and #LCD_NOT_E_BIT
    ; lda lower order bits
    sta PORTB
    nop

    rts

lcd_write_char:
    jsr lcd_wait_busy
    
    tax
    ; lda (LCD_E_BIT | LCD_RS_BIT | higher order bits)
    and #%11110000
    lsr
    lsr
    lsr
    lsr
    ora #(LCD_E_BIT | LCD_RS_BIT)
    sta PORTB
    nop

    ; remove LCD_E_BIT from A register
    and #LCD_NOT_E_BIT
    ; lda higher order bits
    sta PORTB
    nop

    txa
    ; lda (LCD_E_BIT | LCD_RS_BIT | lower order bits)
    and #%00001111
    ora #(LCD_E_BIT | LCD_RS_BIT)
    sta PORTB
    nop

    ; remove LCD_E_BIT from A register
    and #LCD_NOT_E_BIT
    ; lda lower order bits
    sta PORTB
    nop

    rts

; Wait for some time for LCD to switch between instruction mode and char write mode (somehow required, despite busy flag check)
lcd_setup_delay:
    ldx #255
lcd_setup_delay_internal:
    nop
    dex
    bne lcd_setup_delay_internal
    rts