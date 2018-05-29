CHROUT    = $ffd2

SCREEN    = $0400
SCR_CO    = $d800
RST_LN    = $d012
INT_STA   = $d019
BDR_CO    = $d020
BKG_CO    = $d021

COUNT     = 8
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

          ldx #0
loop:     lda #$a0
          sta SCREEN,x

          txa
          sta SCR_CO,x
          inx
          cpx #$10
          bne loop

          ; color row 2 green
          lda #$5
          ldx #0
loop2:    sta SCR_CO + 40,x
          inx
          cpx #40
          bne loop2

          ; init cnt
          lda #COUNT
          sta cnt

          ldy #0    ; init position
          ; wait until raster hit bottom border
mloop:    lda #$ff
l1:       cmp RST_LN
          bne l1

          ; if not time to update, burn more cycles
          lda cnt
          bne burn

          ; clear row
          ldx #0
          lda #$20
l2:       sta SCREEN + 40,x
          inx
          cpx #40
          bne l2

          ; turn on next block
          lda #$a0          
          sta SCREEN + 40,y

          lda #COUNT
          sta cnt
          iny
          cpy #40
          bne next
          ldy #0
          jmp mloop

          ; enough cycles for raster to pass line $ff (63 cycles a line)
burn:     ldx #13
l3:       dex
          bne l3

          dec cnt

next:     jmp mloop
