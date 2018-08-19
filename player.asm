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

          .rodata
player_attrs:
          .byte 0,0,24,17

          .bss
player:   .tag Player
