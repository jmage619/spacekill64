          .include "zeropage.inc"
          .include "sys.inc"
          .include "screen.inc"
          .include "player.inc"
          .include "sprites.inc"

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

          .data
player_attrs:
          .byte 0,0,24,17

          .bss
player:   .tag Player
