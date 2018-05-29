CHROUT    = $ffd2

SCREEN    = $0400
SCR_CO    = $d800
RST_LN    = $d012
INT_CTL   = $d01a
INT_STA   = $d019
BDR_CO    = $d020
BKG_CO    = $d021

pos       = $02

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

          ; initialize position
          lda #$0
          sta pos

          sei

          ; turn off CIA timers
          lda #$7f
          sta $dc0d
          sta $dd0d

          ; clear pending CIA timer interrupts
          lda $dc0d
          lda $dd0d

          ; enable raster interrupt
          lda #$01
          sta INT_CTL

          ; point interrupt to irq
          lda #<irq
          sta $314
          lda #>irq
          sta $315

          ; fire interrupt when hit bottom border
          lda #$ff
          sta RST_LN
          lda RST_LN - 1
          and #$7f
          sta RST_LN - 1

          cli
          jmp *

irq:
          ; ack raster IRQ
          dec INT_STA         

          ; clear row
          ldx #0
l1:       lda #$20
          sta SCREEN + 40,x
          inx
          cpx #40
          bne l1

          ; turn on next block
          ldx pos
          lda #$a0          
          sta SCREEN + 40,x
          inx
          cpx #40
          bne skip
          ldx #0
skip:     stx pos

          jmp $ea31
