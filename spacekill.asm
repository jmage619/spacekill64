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
y_chr     = $04
scr_p     = $05
wtmp      = $07

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
          lda #31
          sta SPR_X
          lda #57
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
          jmp bullet

no_hit:   lda #1              ; otherwise color white
          sta SPR_CO

;burn:     ldx #13             ; enough cycles for raster to pass
;l3:       dex                 ; line $ff (63 cycles a line)
;          bne l3

bullet:   lda #0              ; convert sprite coords to char coords
          sta wtmp+1          ; store sprite x to tmp var to handle
          lda #1              ; hi bit
          bit SPR_MX
          beq lo
          sta wtmp+1

lo:       lda SPR_X
          sta wtmp

          sec                 ; border compensation
          sbc #24
          sta wtmp
          lda wtmp + 1
          sbc #0
          sta wtmp + 1

          lda wtmp
          lsr wtmp + 1        ; divide by 8
          ror
          lsr
          lsr

          clc
          adc #4              ; correct x pos rel to sprite
          sta x_chr

          lda SPR_Y           ; get y
          sec
          sbc #50             ; border compensation
          lsr                 ; divide by 8
          lsr
          lsr

          clc
          adc #1              ; correct y pos rel to sprite
          sta y_chr

          lda y_chr
          asl
          tax
          lda scr_rt,x
          sta scr_p
          lda scr_rt + 1,x
          sta scr_p + 1

          ldy x_chr
          lda #$a0
          sta (scr_p),y

next:     jmp mloop
          .byte 'e','n','d'

          .rodata
          .byte 'r','o','d'
scr_rt:   .word SCREEN+ 0*40, SCREEN+ 1*40, SCREEN+ 2*40, SCREEN+ 3*40, SCREEN+ 4*40
          .word SCREEN+ 5*40, SCREEN+ 6*40, SCREEN+ 7*40, SCREEN+ 8*40, SCREEN +9*40
          .word SCREEN+10*40, SCREEN+11*40, SCREEN+12*40, SCREEN+13*40, SCREEN+14*40
          .word SCREEN+15*40, SCREEN+16*40, SCREEN+17*40, SCREEN+18*40, SCREEN+19*40
          .word SCREEN+20*40, SCREEN+21*40, SCREEN+22*40, SCREEN+23*40, SCREEN+24*40

          .segment "SPRITES"
sprite:   .byte %00011000, %00000000, %00000000
          .byte %00011111, %11000000, %00000000
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
          .byte %00000000, %00000000, %00000000
          .byte %00000000, %00000000, %00000000
