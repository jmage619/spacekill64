          .include "zeropage.inc"
          .include "screen.inc"

          .code
.proc     clr_screen
          ldx #48
l1:       lda scr_rt,x
          sta scr_p
          lda scr_rt+1,x
          sta scr_p+1

          lda #0
          ldy #39
l2:       sta (scr_p),y
          dey
          bpl l2

          dex
          dex
          bpl l1

          rts
.endproc

          .data
scr_rt:   .word SCREEN+ 0*40, SCREEN+ 1*40, SCREEN+ 2*40, SCREEN+ 3*40, SCREEN+ 4*40
          .word SCREEN+ 5*40, SCREEN+ 6*40, SCREEN+ 7*40, SCREEN+ 8*40, SCREEN +9*40
          .word SCREEN+10*40, SCREEN+11*40, SCREEN+12*40, SCREEN+13*40, SCREEN+14*40
          .word SCREEN+15*40, SCREEN+16*40, SCREEN+17*40, SCREEN+18*40, SCREEN+19*40
          .word SCREEN+20*40, SCREEN+21*40, SCREEN+22*40, SCREEN+23*40, SCREEN+24*40
