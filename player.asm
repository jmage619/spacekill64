          .include "globals.inc"
          .include "screen.inc"
          .include "player.inc"

          .code
.proc     init_player
          lda #0
          sta player+Player::_x+1
          sta player+Player::_y+1
          lda #24
          sta player+Player::_x
          lda #50
          sta player+Player::_y

          ldy #0
          lda #1
l1:       bit SPR_EN                    ; search for first avail sprite
          beq set
          asl
          iny
          cpy #8
          bne l1                        ; bail out if none found

return:   rts

set:      sta player+Player::sflag      ; save sprite flag
          ora SPR_EN                    ; define player sprite
          sta SPR_EN
          tya
          sta player+Player::id         ; save offset
          lda #<(sprite / 64)
          sta SPR_P,y
          lda #1
          sta SPR_CO,y

          jmp return
.endproc

.proc     update_player
          lda player+Player::_x         ; update bounding box x sides
          clc
          adc player_attrs+PAttrs::dx
          sta player+Player::bx1
          lda player+Player::_x+1
          adc #0
          sta player+Player::bx1+1

          lda player_attrs+PAttrs::w    ; subtract 1 from w to get rhs
          sta _a
          dec _a

          lda player+Player::bx1
          clc
          adc _a
          sta player+Player::bx2
          lda player+Player::bx1+1
          adc #0
          sta player+Player::bx2+1

          lda player+Player::_y         ; update bounding box y sides
          clc
          adc player_attrs+PAttrs::dy
          sta player+Player::by1
          lda player+Player::_y+1
          adc #0
          sta player+Player::by1+1

          lda player_attrs+PAttrs::h    ; subtract 1 from h to get bottom
          sta _a
          dec _a

          lda player+Player::by1
          clc
          adc _a
          sta player+Player::by2
          lda player+Player::by1+1
          adc #0
          sta player+Player::by2+1

          lda player+Player::id
          asl
          tax
          lda player+Player::_x         ; update sprite x
          sta SPR_X,x
          lda player+Player::_x+1
          beq clrx

          lda SPR_MX
          ora player+Player::sflag
          sta SPR_MX
          jmp sy

clrx:     lda player+Player::sflag
          eor #$ff
          and SPR_MX
          sta SPR_MX

sy:       lda player+Player::_y         ; update sprite y
          sta SPR_Y,x

          rts
.endproc

.proc     bkg_hit
          lda #0
          sta _d
          lda player+Player::by1        ; first row
          sec
          sbc #50
          sta wa
          lda player+Player::by1+1
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

          lda player+Player::by2        ; last row
          sec
          sbc #50
          sta wa
          lda player+Player::by2+1
          sbc #0
          lsr
          ror wa
          lsr
          ror wa
          lsr
          lda wa
          ror
          asl                           ; mult by 2 to get row offset (word sized)
          tax

          lda player+Player::bx1        ; first col
          sec
          sbc #24
          sta wa
          lda player+Player::bx1+1
          sbc #0
          lsr
          ror wa
          lsr
          ror wa
          lsr
          ror wa

          lda wa
          sta _b

          lda player+Player::bx2        ; last col
          sec
          sbc #24
          sta wa
          lda player+Player::bx2+1
          sbc #0
          lsr
          ror wa
          lsr
          ror wa
          lsr
          ror wa

          lda wa
          sta _c

l1:       lda scr_rt,x
          sta scr_p
          lda scr_rt+1,x
          sta scr_p+1

          ldy _c
l2:       lda (scr_p),y
          beq next                      ; skip to next tile if empty
          and #$80                      ; bkg tile hit?
          bne test_pb
          lda _d
          ora #1
          sta _d

test_pb:  lda (scr_p),y                 ; player bullet hit?
          and #$f0
          cmp #$80
          bne test_eb
          lda _d
          ora #1<<1
          sta _d

test_eb:  lda (scr_p),y                 ; enemy bullet hit?
          and #$f0
          cmp #$90
          bne next
          lda _d
          ora #1<<2
          sta _d

next:     dey
          cpy _b
          bpl l2

          dex
          dex
          cpx _a
          bpl l1

          lda _d
          rts
.endproc

          .data
player_attrs:
          .byte 0,0,24,17

          .bss
player:   .tag Player
