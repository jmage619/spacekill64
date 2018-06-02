          .include "input.inc"
          .include "zeropage.inc"

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
SPR_CLB   = $d01f

speed     = 2
x_chr     = $03

          .code

          lda #$0b            ; gray border
          sta BDR_CO          

          lda #$00            ; black background
          sta BKG_CO

          lda #$93            ; clear screen
          jsr CHROUT

          lda #$a0
          sta SCREEN + 5 * 40 + 10

          jsr init_input

          lda #<(sprite / 64) ; define sprite
          sta SPR_P
          lda #$1
          ora SPR_EN
          sta SPR_EN
          lda #1
          sta SPR_CO
          lda #24
          sta SPR_X
          lda #50
          sta SPR_Y

          ldy #0              ; init position
mloop:    lda #$ff            ; wait until raster hit bottom border
l1:       cmp RST_LN
          bne l1
                              ; display should be updated first as much as possible

          jsr read_input      ; get input

                              ; update sprite pos
          lda #1<<1           ; check L
          bit INPUT
          beq check_R
          lda SPR_X
          sec
          sbc #speed
          sta SPR_X
          bcs check_R         ; if borrow, clear upper bit of SPR_X

          lda SPR_MX
          and #<~1
          sta SPR_MX

check_R:  lda #1<<3
          bit INPUT
          beq check_U
          lda SPR_X
          clc
          adc #speed
          sta SPR_X
          bcc check_U         ; if carry, set upper bit of SPR_X

          lda #1
          ora SPR_MX
          sta SPR_MX

check_U:  lda #1
          bit INPUT
          beq check_D
          lda SPR_Y
          sec
          sbc #speed
          sta SPR_Y

check_D:  lda #1<<2
          bit INPUT
          beq chk_hit
          lda SPR_Y
          clc
          adc #speed
          sta SPR_Y

chk_hit:  lda #1              ; check if sprite hit background
          bit SPR_CLB
          beq no_hit

          lda #2              ; color red if hit
          sta SPR_CO
          jmp next

no_hit:   lda #1              ; otherwise color white
          sta SPR_CO

;burn:     ldx #13             ; enough cycles for raster to pass
;l3:       dex                 ; line $ff (63 cycles a line)
;          bne l3

          lda SPR_X           ; convert sprite coords to char coords
          sec
          sbc #24             ; border compensation
          lsr                 ; start dividing by 8
          tax
          lda #1
          bit SPR_MX          ; rotate in the high bit if set
          beq shift2

          txa
          ora #$80
          tax

shift2:   txa                 ; finish dividing
          lsr
          lsr

          sta x_chr

next:     jmp mloop
          .byte 'e','n','d'

          .segment "SPRITES"
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
