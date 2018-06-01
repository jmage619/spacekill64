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

COUNT     = 3
cnt       = $03

          .code

          lda #$0b            ; gray border
          sta BDR_CO          

          lda #$00            ; black background
          sta BKG_CO

          lda #$93            ; clear screen
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

;          lda #$5             ; color row 2 green
;          ldx #0
;loop2:    sta SCR_CO + 40,x
;          inx
;          cpx #40
;          bne loop2

          lda #COUNT          ; init cnt
          sta cnt

          jsr init_input

          lda #<(sprite / 64) ; define sprite
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

          ldy #0              ; init position
mloop:    lda #$ff            ; wait until raster hit bottom border
l1:       cmp RST_LN
          bne l1

          lda #1<<1           ; check L
          bit INPUT
          beq check_R

          dec SPR_X
          dec SPR_X

check_R:  lda #1<<3
          bit INPUT
          beq check_U
          inc SPR_X
          inc SPR_X

check_U:  lda #1
          bit INPUT
          beq check_D
          dec SPR_Y
          dec SPR_Y

check_D:  lda #1<<2
          bit INPUT
          beq next_in
          inc SPR_Y
          inc SPR_Y

;          lda cnt             ; if not time to update, burn more cycles
;          bne burn
;
;          ldx #0              ; clear row
;          lda #$20
;l2:       sta SCREEN + 40,x
;          inx
;          cpx #40
;          bne l2
;
;          lda #$a0           ; turn on next block
;          sta SCREEN + 40,y
;
;          lda #COUNT
;          sta cnt
;          iny
;          cpy #40
;          bne next
;          ldy #0
;          jmp mloop
          
;burn:     ldx #13             ; enough cycles for raster to pass
;l3:       dex                 ; line $ff (63 cycles a line)
;          bne l3
next_in:   jsr read_input

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
