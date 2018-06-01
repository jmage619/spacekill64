CHROUT    = $ffd2

SCREEN    = $0400
SPR_P     = $07f8
SCR_CO    = $d800
RST_LN    = $d012
INT_STA   = $d019
BDR_CO    = $d020
BKG_CO    = $d021
SPR_EN    = $d015
SPR_CO    = $d027
SPR_X     = $d000
SPR_Y     = $d001
SPR_MX    = $d010

COUNT     = 3
cnt       = $02

          .code

          ; gray border
          lda #$0b
          sta BDR_CO          

          ; black background
          lda #$00
          sta BKG_CO

          ; clear screen
          lda #$93
          jsr CHROUT

;          ldx #0
;loop:     lda #$a0
;          sta SCREEN,x
;
;          txa
;          sta SCR_CO,x
;          inx
;          cpx #$10
;          bne loop

;          ; color row 2 green
;          lda #$5
;          ldx #0
;loop2:    sta SCR_CO + 40,x
;          inx
;          cpx #40
;          bne loop2

          ; init cnt
          lda #COUNT
          sta cnt

          ; define sprite
          lda #<(sprite / 64)
          sta SPR_P
          lda #$1
          ora SPR_EN
          sta SPR_EN
          lda #1
          sta SPR_CO
          lda #30
          sta SPR_X
          lda #80
          sta SPR_Y
          

          ldy #0    ; init position
          ; wait until raster hit bottom border
mloop:    lda #$ff
l1:       cmp RST_LN
          bne l1

;          ; if not time to update, burn more cycles
;          lda cnt
;          bne burn
;
;          ; clear row
;          ldx #0
;          lda #$20
;l2:       sta SCREEN + 40,x
;          inx
;          cpx #40
;          bne l2
;
;          ; turn on next block
;          lda #$a0          
;          sta SCREEN + 40,y
;
;          lda #COUNT
;          sta cnt
;          iny
;          cpy #40
;          bne next
;          ldy #0
;          jmp mloop

          ; enough cycles for raster to pass line $ff (63 cycles a line)
burn:     ldx #13
l3:       dex
          bne l3

;          dec cnt

next:     jmp mloop

          .data
sprite:   .byte %00010000, %00000000, %00000000
          .byte %00011100, %00000000, %00000000
          .byte %00010011, %00000000, %00000000
          .byte %00010011, %11000000, %00000000
          .byte %00010011, %10110000, %00000000
          .byte %00010011, %10001100, %00000000
          .byte %00110011, %10000011, %00000000
          .byte %00110011, %11000000, %11000000
          .byte %01110011, %11100000, %00110000
          .byte %11110011, %11111111, %11111100
          .byte %11110000, %11111111, %11111111
          .byte %11110000, %00111111, %11111110
          .byte %01110000, %00010101, %01010100
          .byte %00110000, %00101010, %10101000
          .byte %00110000, %01010101, %00010000
          .byte %00010000, %00000000, %11100000
          .byte %00010000, %11111111, %00000000
          .byte %00010001, %00000000, %00000000
          .byte %00011110, %00000000, %00000000
          .byte %00000000, %00000000, %00000000
          .byte %00000000, %00000000, %00000000
