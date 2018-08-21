          .include "zeropage.inc"
          .include "screen.inc"

          .code
.proc     clr_screen
          lda #0
          ldx #99
l1:       sta SCREEN,x
          sta SCREEN+100,x
          sta SCREEN+200,x
          sta SCREEN+300,x
          sta SCREEN+400,x
          sta SCREEN+500,x
          sta SCREEN+600,x
          sta SCREEN+700,x
          sta SCREEN+800,x
          sta SCREEN+900,x
          
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
