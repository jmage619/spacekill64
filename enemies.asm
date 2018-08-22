          .include "globals.inc"
          .include "screen.inc"
          .include "enemies.inc"

          .code
.proc     init_enemies
          lda #$ff
          ldx #0
next:     sta enemies+Enemies::id,x
          inx
          inx
          cpx #2 * 8
          bne next
          rts
.endproc

; input enemy index in x reg
.proc     create_enemy
          ldy #0
          lda #1
l1:       bit SPR_EN                    ; search for first avail sprite
          beq set
          asl
          iny
          cpy #8
          bne l1                        ; bail out if none found

return:   rts

set:      sta enemies+Enemies::sflag,x  ; save sprite flag
          ora SPR_EN                    ; define enemy sprite
          sta SPR_EN
          tya
          sta enemies+Enemies::id,x     ; save offset
          lda #<(sprite2 / 64)
          sta SPR_P,y
          sta SPR_P2,y
          lda #13
          sta SPR_CO,y

          jmp return
.endproc

.proc     update_enemies
          ldy #14
l1:       lda enemies+Enemies::id,y
          bpl update
          dey
          dey
          bpl l1

          jmp return

update:   lda enemies+Enemies::_x,y         ; update bounding box x sides
          clc
          adc enemy_attrs+EAttrs::dx
          sta enemies+Enemies::bx1,y
          lda enemies+Enemies::_x+1,y
          adc #0
          sta enemies+Enemies::bx1+1,y

          lda enemy_attrs+EAttrs::w    ; subtract 1 from w to get rhs
          sta _a
          dec _a

          lda enemies+Enemies::bx1,y
          clc
          adc _a
          sta enemies+Enemies::bx2,y
          lda enemies+Enemies::bx1+1,y
          adc #0
          sta enemies+Enemies::bx2+1,y

          lda enemies+Enemies::_y,y      ; update bounding box y sides
          clc
          adc enemy_attrs+EAttrs::dy
          sta enemies+Enemies::by1,y
          lda enemies+Enemies::_y+1,y
          adc #0
          sta enemies+Enemies::by1+1,y

          lda enemy_attrs+EAttrs::h    ; subtract 1 from h to get bottom
          sta _a
          dec _a

          lda enemies+Enemies::by1,y
          clc
          adc _a
          sta enemies+Enemies::by2,y
          lda enemies+Enemies::by1+1,y
          adc #0
          sta enemies+Enemies::by2+1,y

          lda enemies+Enemies::id,y
          asl
          tax
          lda enemies+Enemies::_x,y         ; update sprite x
          sta SPR_X,x
          lda enemies+Enemies::_x+1,y
          beq clrx

          lda SPR_MX
          ora enemies+Enemies::sflag,y
          sta SPR_MX
          jmp sy

clrx:     lda enemies+Enemies::sflag,y
          eor #$ff
          and SPR_MX
          sta SPR_MX

sy:       lda enemies+Enemies::_y,y         ; update sprite y
          sta SPR_Y,x

          dey
          dey
          bmi return
          jmp l1

return:   rts
.endproc

; input enemy index in x reg
.proc     ebkg_hit
          lda #0
          sta _e
          lda enemies+Enemies::by1,x      ; first row
          sec
          sbc #50
          sta wa
          lda enemies+Enemies::by1+1,x
          sbc #0
          lsr
          ror wa
          lsr
          ror wa
          lsr
          lda wa
          ror
          asl                           ; mult by 2 to get row offset (word sized)
          sta _a

          lda enemies+Enemies::by2,x    ; last row
          sec
          sbc #50
          sta wa
          lda enemies+Enemies::by2+1,x
          sbc #0
          lsr
          ror wa
          lsr
          ror wa
          lsr
          lda wa
          ror
          asl                           ; mult by 2 to get row offset (word sized)
          sta _b

          lda enemies+Enemies::bx1,x    ; first col
          sec
          sbc #24
          sta wa
          lda enemies+Enemies::bx1+1,x
          sbc #0
          lsr
          ror wa
          lsr
          ror wa
          lsr
          ror wa

          lda wa
          sta _c

          lda enemies+Enemies::bx2,x    ; last col
          sec
          sbc #24
          sta wa
          lda enemies+Enemies::bx2+1,x
          sbc #0
          lsr
          ror wa
          lsr
          ror wa
          lsr
          ror wa

          lda wa
          sta _d

          stx _f
          ldx _b
l1:       lda scr_rt,x
          sta scr_p
          lda scr_rt+1,x
          sta scr_p+1

          ldy _d
l2:       lda (scr_p),y
          beq next                      ; skip to next tile if empty
          and #$80                      ; bkg tile hit?
          bne test_pb
          lda _e
          ora #1
          sta _e

test_pb:  lda (scr_p),y                 ; player bullet hit?
          and #$f0
          cmp #$80
          bne next
          lda _e
          ora #1<<1
          sta _e

next:     dey
          cpy _c
          bpl l2

          dex
          dex
          cpx _a
          bpl l1

          lda _e
          ldx _f
          rts
.endproc

          .data
enemy_attrs:
          .byte 0, 1, 20, 18

          .bss
enemies:  .tag Enemies
