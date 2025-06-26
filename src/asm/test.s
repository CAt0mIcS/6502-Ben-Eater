    .org $8000

reset:
    ; Set Data Direction Register B to output
    lda #$ff
    sta $6002

loop:
    ; Output 55 to Register B
    lda #$55
    sta $6000

    ; Output AA to Register B
    lda #$aa
    sta $6000

    jmp loop

    .org $fffc
    .word reset
    .word $0000