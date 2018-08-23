          .include "globals.inc"
          .include "screen.inc"
          .include "bullets.inc"

          .code
.proc     init_bullets
          lda #0
          ldx #0
next:     sta bullets+Bullets::flags,x
          inx
          cpx #8
          bne next
          rts
.endproc

.proc     create_bullet
          ldx #0
l1:       lda bullets+Bullets::flags,x ; look for first available bullet
          and #1
          beq coords
          inx
          cpx #8
          beq return                   ; if none available just exit
          jmp l1

coords:   lda bullets+Bullets::flags,x
          ora #1
          sta bullets+Bullets::flags,x
          lda #0              ; convert sprite coords to char coords
          sta wa+1          ; store sprite x to tmp var to handle
          lda #1              ; hi bit
          bit SPR_MX
          beq lo
          sta wa+1

lo:       lda SPR_X
          sta wa

          sec                 ; border compensation
          sbc #24
          sta wa
          lda wa + 1
          sbc #0
          sta wa + 1

          lda VIC_MOD                   ; get scroll pos
          and #07
          sta _a

          lda wa                        ; subtract scroll
          sec
          sbc _a
          sta wa
          lda wa+1
          sbc #0
          sta wa+1

          lda wa
          lsr wa + 1        ; divide by 8
          ror
          lsr
          lsr

          clc
          adc #2              ; correct x pos rel to sprite
          sta bullets+Bullets::j,x

          lda SPR_Y           ; get y
          sec
          sbc #50             ; border compensation
          lsr                 ; divide by 8
          lsr
          lsr

          clc
          adc #1              ; correct y pos rel to sprite
          sta bullets+Bullets::i,x
return:   rts
.endproc

.proc     update_bullets
          ldx #0
l1:       lda bullets+Bullets::flags,x
          and #1
          beq next
          lda bullets+Bullets::i,x
          asl

          tay
          lda scr_flag
          bne e1
          lda scr_rt2,y
          sta scr_p
          lda scr_rt2 + 1,y
          sta scr_p + 1
          jmp clr_buf

e1:       lda scr_rt,y
          sta scr_p
          lda scr_rt + 1,y
          sta scr_p + 1

clr_buf:
          sty _a
          ldy bullets+Bullets::j,x
          lda #$00
          dey
          sta (scr_p),y
          iny
          sta (scr_p),y

          ldy _a
          lda scr_flag
          beq e2
          lda scr_rt2,y
          sta scr_p
          lda scr_rt2 + 1,y
          sta scr_p + 1
          jmp clr_cur

e2:       lda scr_rt,y
          sta scr_p
          lda scr_rt + 1,y
          sta scr_p + 1

clr_cur:  ldy bullets+Bullets::j,x
          lda #$00                      ; blank out prev on screen
          sta (scr_p),y
          cmp fcnt                      ; blank one to the left if scroll displaced bullet
          bne e3
          dey
          sta (scr_p),y
          iny
          jmp s3

e3:       iny                           ; otherwise blank one to right
          sta (scr_p),y
          dey

s3:       iny
          cpy #39
          beq disable
          lda (scr_p),y
          bne disable
          iny
          lda (scr_p),y
          bne disable
          dey

          tya
          sta bullets+Bullets::j,x      ; update bullet on screen
          lda #$80
          sta (scr_p),y
          iny
          lda #$81
          sta (scr_p),y
next:     inx
          cpx #8
          beq return
          jmp l1

return:   rts

disable:  lda bullets+Bullets::flags,x
          and #<~1
          sta bullets+Bullets::flags,x
          jmp next
.endproc

          .bss
bullets:  .tag Bullets
