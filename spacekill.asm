          .include "input.inc"
          .include "zeropage.inc"
          .include "sys.inc"
          .include "screen.inc"
          .include "sprites.inc"
          .include "player.inc"
          .include "enemies.inc"
          .include "bullets.inc"

CHARS     = $3800

speed     = 2

          .code; custom char set at $3800
          lda #5
          ldx #<chr_fname
          ldy #>chr_fname
          jsr SETNAM
          lda #1
          ldx #8
          ldy #0
          jsr SETLFS
          ldx #<CHARS
          ldy #>CHARS
          lda #0
          jsr LOAD

          lda VIC_CTL         ; point to char set
          and #$f0
          ora #14
          sta VIC_CTL

          lda #$0b            ; gray border
          sta BDR_CO          

          lda #$00            ; black background
          sta BKG_CO

          jsr clr_screen      ; clear screen

          lda #$01
          sta SCREEN + 5 * 40 + 10

          lda #0
          sta flags
          jsr init_input

          jsr init_player
          lda #31
          sta player+Player::_x
          lda #57
          sta player+Player::_y

          jsr update_player

          jsr init_enemies

          lda #255
          sta enemies+Enemies::_x
          lda #0
          sta enemies+Enemies::_x+1
          lda #128
          sta enemies+Enemies::_y
          lda #0
          sta enemies+Enemies::_y+1

          ldx #0
          jsr create_enemy
          jsr update_enemies

          jsr init_bullets

          ldy #0              ; init position
mloop:    lda #$ff            ; wait until raster hit bottom border
l1:       cmp RST_LN
          bne l1

          jsr read_input      ; get input

          lda SPR_CLB                   ; test if player hit background
          sta tmp                       ; store bkg collision for enemy tests
          bit player+Player::sflag
          beq no_hit
          jsr bkg_hit
          and #1
          beq no_hit

          lda #2              ; color red if hit
          ldx player+Player::id
          sta SPR_CO,x
          jmp echk

no_hit:   lda #1              ; otherwise color white
          ldx player+Player::id
          sta SPR_CO,x

echk:     ldx #14                       ; loop through enemies to find a hit
l2:       lda enemies+Enemies::id,x
          bmi n2

          lda tmp
          and enemies+Enemies::sflag,x
          beq eno_hit
          jsr ebkg_hit
          and #1<<1
          beq eno_hit

          lda #2
          ldy enemies+Enemies::id,x
          sta SPR_CO,y
          jmp n2

eno_hit:  lda #13
          ldy enemies+Enemies::id,x
          sta SPR_CO,y

n2:       dex
          dex
          bpl l2

input:                        ; handle user input
          lda #1<<1           ; check L
          bit INPUT
          beq check_R
          lda player+Player::_x
          sec
          sbc #speed
          sta player+Player::_x
          lda player+Player::_x+1
          sbc #0
          sta player+Player::_x+1

check_R:  lda #1<<3
          bit INPUT
          beq check_U
          lda player+Player::_x
          clc
          adc #speed
          sta player+Player::_x
          lda player+Player::_x+1
          adc #0
          sta player+Player::_x+1

check_U:  lda #1
          bit INPUT
          beq check_D
          lda player+Player::_y
          sec
          sbc #speed
          sta player+Player::_y

check_D:  lda #1<<2
          bit INPUT
          beq upd_pl
          lda player+Player::_y
          clc
          adc #speed
          sta player+Player::_y

upd_pl:   jsr update_player

          lda #1<<4           ; shoot if K pressed
          bit INPUT
          beq fire_off

          lda #1              ; only fire if not pressed previously
          bit flags
          bne fire_on
          jsr create_bullet
fire_on:  lda flags           ; set pressed
          ora #1
          sta flags
          jmp update

fire_off: lda flags           ; clear pressed
          and #<~1
          sta flags

update:   jsr update_bullets

          jmp mloop

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
          sta wtmp1
          lda enemies+Enemies::by1+1,x
          sbc #0
          lsr
          ror wtmp1
          lsr
          ror wtmp1
          lsr
          lda wtmp1
          ror
          asl                           ; mult by 2 to get row offset (word sized)
          sta _a

          lda enemies+Enemies::by2,x    ; last row
          sec
          sbc #50
          sta wtmp1
          lda enemies+Enemies::by2+1,x
          sbc #0
          lsr
          ror wtmp1
          lsr
          ror wtmp1
          lsr
          lda wtmp1
          ror
          asl                           ; mult by 2 to get row offset (word sized)
          sta _b

          lda enemies+Enemies::bx1,x    ; first col
          sec
          sbc #24
          sta wtmp1
          lda enemies+Enemies::bx1+1,x
          sbc #0
          lsr
          ror wtmp1
          lsr
          ror wtmp1
          lsr
          ror wtmp1

          lda wtmp1
          sta _c

          lda enemies+Enemies::bx2,x    ; last col
          sec
          sbc #24
          sta wtmp1
          lda enemies+Enemies::bx2+1,x
          sbc #0
          lsr
          ror wtmp1
          lsr
          ror wtmp1
          lsr
          ror wtmp1

          lda wtmp1
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
chr_fname:
          .byte "chars"
