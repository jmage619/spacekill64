          .include "globals.inc"
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

.proc     clr_screen2
          lda #0
          ldx #99
l1:       sta SCREEN2,x
          sta SCREEN2+100,x
          sta SCREEN2+200,x
          sta SCREEN2+300,x
          sta SCREEN2+400,x
          sta SCREEN2+500,x
          sta SCREEN2+600,x
          sta SCREEN2+700,x
          sta SCREEN2+800,x
          sta SCREEN2+900,x

          dex
          bpl l1

          rts
.endproc

; fill last column of screen
; from data pointing at data_ptr
.proc     fill_scrcol
          ldy #0
          lda (data_ptr),y
          sta SCREEN+39
          iny
          lda (data_ptr),y
          sta SCREEN+79
          iny
          lda (data_ptr),y
          sta SCREEN+119
          iny
          lda (data_ptr),y
          sta SCREEN+159
          iny
          lda (data_ptr),y
          sta SCREEN+199
          iny
          lda (data_ptr),y
          sta SCREEN+239
          iny
          lda (data_ptr),y
          sta SCREEN+279
          iny
          lda (data_ptr),y
          sta SCREEN+319
          iny
          lda (data_ptr),y
          sta SCREEN+359
          iny
          lda (data_ptr),y
          sta SCREEN+399
          iny
          lda (data_ptr),y
          sta SCREEN+439
          iny
          lda (data_ptr),y
          sta SCREEN+479
          iny
          lda (data_ptr),y
          sta SCREEN+519
          iny
          lda (data_ptr),y
          sta SCREEN+559
          iny
          lda (data_ptr),y
          sta SCREEN+599
          iny
          lda (data_ptr),y
          sta SCREEN+639
          iny
          lda (data_ptr),y
          sta SCREEN+679
          iny
          lda (data_ptr),y
          sta SCREEN+719
          iny
          lda (data_ptr),y
          sta SCREEN+759
          iny
          lda (data_ptr),y
          sta SCREEN+799
          iny
          lda (data_ptr),y
          sta SCREEN+839
          iny
          lda (data_ptr),y
          sta SCREEN+879
          iny
          lda (data_ptr),y
          sta SCREEN+919
          iny
          lda (data_ptr),y
          sta SCREEN+959
          iny
          lda (data_ptr),y
          sta SCREEN+999

return:   rts
.endproc

.proc     fill_scrcol2
          ldy #0
          lda (data_ptr),y
          sta SCREEN2+39
          iny
          lda (data_ptr),y
          sta SCREEN2+79
          iny
          lda (data_ptr),y
          sta SCREEN2+119
          iny
          lda (data_ptr),y
          sta SCREEN2+159
          iny
          lda (data_ptr),y
          sta SCREEN2+199
          iny
          lda (data_ptr),y
          sta SCREEN2+239
          iny
          lda (data_ptr),y
          sta SCREEN2+279
          iny
          lda (data_ptr),y
          sta SCREEN2+319
          iny
          lda (data_ptr),y
          sta SCREEN2+359
          iny
          lda (data_ptr),y
          sta SCREEN2+399
          iny
          lda (data_ptr),y
          sta SCREEN2+439
          iny
          lda (data_ptr),y
          sta SCREEN2+479
          iny
          lda (data_ptr),y
          sta SCREEN2+519
          iny
          lda (data_ptr),y
          sta SCREEN2+559
          iny
          lda (data_ptr),y
          sta SCREEN2+599
          iny
          lda (data_ptr),y
          sta SCREEN2+639
          iny
          lda (data_ptr),y
          sta SCREEN2+679
          iny
          lda (data_ptr),y
          sta SCREEN2+719
          iny
          lda (data_ptr),y
          sta SCREEN2+759
          iny
          lda (data_ptr),y
          sta SCREEN2+799
          iny
          lda (data_ptr),y
          sta SCREEN2+839
          iny
          lda (data_ptr),y
          sta SCREEN2+879
          iny
          lda (data_ptr),y
          sta SCREEN2+919
          iny
          lda (data_ptr),y
          sta SCREEN2+959
          iny
          lda (data_ptr),y
          sta SCREEN2+999

return:   rts
.endproc

; shift 1/8th of a screen at a time
; start index inside x reg
.proc     shift_scr
          cpx #0
          bne chk1
          ldy #0
l0:       lda SCREEN2+1,y
          sta SCREEN,y
          lda SCREEN2+40+1,y
          sta SCREEN+40,y
          lda SCREEN2+80+1,y
          sta SCREEN+80,y
          iny
          cpy #39
          bne l0
          jmp return

chk1:     cpx #1
          bne chk2
          ldy #0
l1:       lda SCREEN2+120+1,y
          sta SCREEN+120,y
          lda SCREEN2+160+1,y
          sta SCREEN+160,y
          lda SCREEN2+200+1,y
          sta SCREEN+200,y
          iny
          cpy #39
          bne l1
          jmp return

chk2:     cpx #2
          bne chk3
          ldy #0
l2:       lda SCREEN2+240+1,y
          sta SCREEN+240,y
          lda SCREEN2+280+1,y
          sta SCREEN+280,y
          lda SCREEN2+320+1,y
          sta SCREEN+320,y
          iny
          cpy #39
          bne l2
          jmp return

chk3:     cpx #3
          bne chk4
          ldy #0
l3:       lda SCREEN2+360+1,y
          sta SCREEN+360,y
          lda SCREEN2+400+1,y
          sta SCREEN+400,y
          lda SCREEN2+440+1,y
          sta SCREEN+440,y
          iny
          cpy #39
          bne l3
          jmp return

chk4:     cpx #4
          bne chk5
          ldy #0
l4:       lda SCREEN2+480+1,y
          sta SCREEN+480,y
          lda SCREEN2+520+1,y
          sta SCREEN+520,y
          lda SCREEN2+560+1,y
          sta SCREEN+560,y
          iny
          cpy #39
          bne l4
          jmp return

chk5:     cpx #5
          bne chk6
          ldy #0
l5:       lda SCREEN2+600+1,y
          sta SCREEN+600,y
          lda SCREEN2+640+1,y
          sta SCREEN+640,y
          lda SCREEN2+680+1,y
          sta SCREEN+680,y
          iny
          cpy #39
          bne l5
          jmp return

chk6:     cpx #6
          bne s7
          ldy #0
l6:       lda SCREEN2+720+1,y
          sta SCREEN+720,y
          lda SCREEN2+760+1,y
          sta SCREEN+760,y
          lda SCREEN2+800+1,y
          sta SCREEN+800,y
          iny
          cpy #39
          bne l6
          jmp return

s7:
          ldy #0
l7:       lda SCREEN2+840+1,y
          sta SCREEN+840,y
          lda SCREEN2+880+1,y
          sta SCREEN+880,y
          lda SCREEN2+920+1,y
          sta SCREEN+920,y
          lda SCREEN2+960+1,y
          sta SCREEN+960,y
          iny
          cpy #39
          beq return
          jmp l7

return:   rts
.endproc

.proc     shift_scr2
          cpx #0
          bne chk1
          ldy #0
l0:       lda SCREEN+1,y
          sta SCREEN2,y
          lda SCREEN+40+1,y
          sta SCREEN2+40,y
          lda SCREEN+80+1,y
          sta SCREEN2+80,y
          iny
          cpy #39
          bne l0
          jmp return

chk1:     cpx #1
          bne chk2
          ldy #0
l1:       lda SCREEN+120+1,y
          sta SCREEN2+120,y
          lda SCREEN+160+1,y
          sta SCREEN2+160,y
          lda SCREEN+200+1,y
          sta SCREEN2+200,y
          iny
          cpy #39
          bne l1
          jmp return

chk2:     cpx #2
          bne chk3
          ldy #0
l2:       lda SCREEN+240+1,y
          sta SCREEN2+240,y
          lda SCREEN+280+1,y
          sta SCREEN2+280,y
          lda SCREEN+320+1,y
          sta SCREEN2+320,y
          iny
          cpy #39
          bne l2
          jmp return

chk3:     cpx #3
          bne chk4
          ldy #0
l3:       lda SCREEN+360+1,y
          sta SCREEN2+360,y
          lda SCREEN+400+1,y
          sta SCREEN2+400,y
          lda SCREEN+440+1,y
          sta SCREEN2+440,y
          iny
          cpy #39
          bne l3
          jmp return

chk4:     cpx #4
          bne chk5
          ldy #0
l4:       lda SCREEN+480+1,y
          sta SCREEN2+480,y
          lda SCREEN+520+1,y
          sta SCREEN2+520,y
          lda SCREEN+560+1,y
          sta SCREEN2+560,y
          iny
          cpy #39
          bne l4
          jmp return

chk5:     cpx #5
          bne chk6
          ldy #0
l5:       lda SCREEN+600+1,y
          sta SCREEN2+600,y
          lda SCREEN+640+1,y
          sta SCREEN2+640,y
          lda SCREEN+680+1,y
          sta SCREEN2+680,y
          iny
          cpy #39
          bne l5
          jmp return

chk6:     cpx #6
          bne s7
          ldy #0
l6:       lda SCREEN+720+1,y
          sta SCREEN2+720,y
          lda SCREEN+760+1,y
          sta SCREEN2+760,y
          lda SCREEN+800+1,y
          sta SCREEN2+800,y
          iny
          cpy #39
          bne l6
          jmp return

s7:
          ldy #0
l7:       lda SCREEN+840+1,y
          sta SCREEN2+840,y
          lda SCREEN+880+1,y
          sta SCREEN2+880,y
          lda SCREEN+920+1,y
          sta SCREEN2+920,y
          lda SCREEN+960+1,y
          sta SCREEN2+960,y
          iny
          cpy #39
          beq return
          jmp l7

return:   rts
.endproc

          .data
scr_rt:   .word SCREEN+ 0*40, SCREEN+ 1*40, SCREEN+ 2*40, SCREEN+ 3*40, SCREEN+ 4*40
          .word SCREEN+ 5*40, SCREEN+ 6*40, SCREEN+ 7*40, SCREEN+ 8*40, SCREEN +9*40
          .word SCREEN+10*40, SCREEN+11*40, SCREEN+12*40, SCREEN+13*40, SCREEN+14*40
          .word SCREEN+15*40, SCREEN+16*40, SCREEN+17*40, SCREEN+18*40, SCREEN+19*40
          .word SCREEN+20*40, SCREEN+21*40, SCREEN+22*40, SCREEN+23*40, SCREEN+24*40

scr_rt2:  .word SCREEN2+ 0*40, SCREEN2+ 1*40, SCREEN2+ 2*40, SCREEN2+ 3*40, SCREEN2+ 4*40
          .word SCREEN2+ 5*40, SCREEN2+ 6*40, SCREEN2+ 7*40, SCREEN2+ 8*40, SCREEN2 +9*40
          .word SCREEN2+10*40, SCREEN2+11*40, SCREEN2+12*40, SCREEN2+13*40, SCREEN2+14*40
          .word SCREEN2+15*40, SCREEN2+16*40, SCREEN2+17*40, SCREEN2+18*40, SCREEN2+19*40
          .word SCREEN2+20*40, SCREEN2+21*40, SCREEN2+22*40, SCREEN2+23*40, SCREEN2+24*40
