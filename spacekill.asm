          .include "input.inc"
          .include "zeropage.inc"

CHROUT    = $ffd2

SCREEN    = $0400
SPR_P     = $07f8
SCR_CO    = $d800
RST_LN    = $d012
VIC_CTL   = $d018
INT_STA   = $d019
BDR_CO    = $d020
BKG_CO    = $d021
SPR_EN    = $d015
SPR_CO    = $d027
SPR_X     = $d000
SPR_Y     = $d001
SPR_MX    = $d010
SPR_CLB   = $d01f

speed     = 2
_a        = $03
_b        = $04
_c        = $05
_d        = $06
x_chr     = $07
y_chr     = $08
flags     = $09
tmp       = $0a
scr_p     = $0b
wtmp1     = $0d
wtmp2     = $0f
wtmp3     = $11
wtmp4     = $13

.scope    Bullet
dx        = 0
dy        = 1
w         = 2
h         = 3
.endscope

.struct   Bullets
flags     .byte 8
i         .byte 8
j         .byte 8
.endstruct

.scope    PAttrs
dx        = 0
dy        = 1
w         = 2
h         = 3
.endscope

.struct   Player
id        .word
sflag     .word
_x        .word
_y        .word
bx1       .word
bx2       .word
by1       .word
by2       .word
.endstruct

.scope    EAttrs
dx        = 0
dy        = 1
w         = 2
h         = 3
.endscope

.struct   Enemies
id        .word 8
sflag     .word 8
_x        .word 8
_y        .word 8
bx1       .word 8
bx2       .word 8
by1       .word 8
by2       .word 8
.endstruct

          .code; custom char set at $3000
          lda #$ff            ; define tile at $01
          sta $3008
          sta $3009
          sta $300a
          sta $300b
          sta $300c
          sta $300d
          sta $300e
          sta $300f

          lda #%00000000      ; define player bullet at $80
          sta $3400
          sta $3401
          lda #%00111100
          sta $3402
          lda #%11111111
          sta $3403
          sta $3404
          lda #%00111100
          sta $3405
          lda #%00000000
          sta $3406
          sta $3407

          lda VIC_CTL         ; point to char set
          and #$f0
          ora #12
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

          ;lda #<(sprite / 64) ; define sprite
          ;sta SPR_P
          ;lda SPR_EN
          ;ora #1
          ;sta SPR_EN
          ;lda #1
          ;sta SPR_CO
          ;lda #31
          ;sta SPR_X
          ;lda #57
          ;sta SPR_Y

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
          bit player+Player::sflag
          beq no_hit
          jsr bkg_hit
          and #1
          beq no_hit

          lda #2              ; color red if hit
          ldx player+Player::id
          sta SPR_CO,x
          jmp input

no_hit:   lda #1              ; otherwise color white
          ldx player+Player::id
          sta SPR_CO,x

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
          ;jmp chk_hit
          jmp update

fire_off: lda flags           ; clear pressed
          and #<~1
          sta flags

;chk_hit:  lda #1              ; check if sprite hit background
;          bit SPR_CLB
;          beq no_hit
;
;          lda #2              ; color red if hit
;          sta SPR_CO
;          jmp update
;
;no_hit:   lda #1              ; otherwise color white
;          sta SPR_CO

;burn:     ldx #13             ; enough cycles for raster to pass
;l3:       dex                 ; line $ff (63 cycles a line)
;          bne l3

update:   jsr update_bullets

;          ldx #0                        ; loop thru bullets and enemies
;l2:       ldy #0
;l3:
;          jsr bullet_hit                ; if hit, color enemy black and break
;          bpl next
;          stx tmp
;          ldx enemies+Enemies::id,y
;          lda #0
;          sta SPR_CO,x
;          ldx tmp
;
;          jmp mloop
;
;next:     iny
;          cpy #8
;          bne l3
;          inx
;          cpx #8
;          bne l2
;
;          lda #1
;          ldx #0
;l4:       sta SPR_CO,x                  ; color all sprites white if no hits
;          inx
;          cpx #8
;          bne l4
;
          jmp mloop

          .byte 'e','n','d'

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
.proc     init_bullets
          lda #0
          ldx #0
next:     sta bullets+Bullets::flags,x
          inx
          cpx #8
          bne next
          rts
.endproc

.proc     bkg_hit
          lda #0
          sta _d
          lda player+Player::by1        ; first row
          sec
          sbc #50
          sta wtmp1
          lda player+Player::by1+1
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

          lda player+Player::by2        ; last row
          sec
          sbc #50
          sta wtmp1
          lda player+Player::by2+1
          sbc #0
          lsr
          ror wtmp1
          lsr
          ror wtmp1
          lsr
          lda wtmp1
          ror
          asl                           ; mult by 2 to get row offset (word sized)
          tax

          lda player+Player::bx1        ; first col
          sec
          sbc #24
          sta wtmp1
          lda player+Player::bx1+1
          sbc #0
          lsr
          ror wtmp1
          lsr
          ror wtmp1
          lsr
          ror wtmp1

          lda wtmp1
          sta _b

          lda player+Player::bx2        ; last col
          sec
          sbc #24
          sta wtmp1
          lda player+Player::bx2+1
          sbc #0
          lsr
          ror wtmp1
          lsr
          ror wtmp1
          lsr
          ror wtmp1

          lda wtmp1
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
          sta wtmp1+1          ; store sprite x to tmp var to handle
          lda #1              ; hi bit
          bit SPR_MX
          beq lo
          sta wtmp1+1

lo:       lda SPR_X
          sta wtmp1

          sec                 ; border compensation
          sbc #24
          sta wtmp1
          lda wtmp1 + 1
          sbc #0
          sta wtmp1 + 1

          lda wtmp1
          lsr wtmp1 + 1        ; divide by 8
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

.byte     'u','d','b'
.proc     update_bullets
          ldx #0
l1:       lda bullets+Bullets::flags,x
          and #1
          beq next
          lda bullets+Bullets::i,x
          asl
          tay
          lda scr_rt,y
          sta scr_p
          lda scr_rt + 1,y
          sta scr_p + 1

          ldy bullets+Bullets::j,x
          lda #$00                      ; blank out prev on screen
          sta (scr_p),y

          iny
          cpy #40
          beq disable

          tya
          sta bullets+Bullets::j,x      ; update bullet on screen
          lda #$80
          sta (scr_p),y
next:     inx
          cpx #8
          bne l1

          rts

disable:  lda bullets+Bullets::flags,x
          and #<~1
          sta bullets+Bullets::flags,x
          jmp next
.endproc

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
          lda #1
          sta SPR_CO,y

          jmp return
.endproc

.proc     update_enemies
          ldy #14
l1:       lda enemies+Enemies::id
          bne update
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

          .byte 'h','i','t'
.proc     bullet_hit
          lda #0
          sta wtmp1+1
          lda bullets+Bullets::j,x
          asl                           ; mult by 8 to translate to px
          rol wtmp1+1
          asl
          rol wtmp1+1
          asl
          rol wtmp1+1

          clc                           ; x border compensation
          adc #24
          sta wtmp1
          lda wtmp1+1
          adc #0
          sta wtmp1+1

          lda wtmp1                     ; add dx
          clc
          adc bullet_attrs+Bullet::dx
          sta wtmp1
          lda wtmp1+1
          adc #0
          sta wtmp1+1

          lda wtmp1                     ; save rhs
          clc
          adc bullet_attrs+Bullet::w
          sta wtmp2
          lda wtmp1+1
          adc #0
          sta wtmp2+1

          lda enemies+Enemies::_x,y     ; get enemy x and add dx
          clc
          adc enemy_attrs+EAttrs::dx
          sta wtmp3
          lda enemies+Enemies::_x+1,y
          adc #0
          sta wtmp3+1

          lda wtmp3                     ; save rhs
          clc
          adc enemy_attrs+EAttrs::w
          sta wtmp4
          lda wtmp3+1
          adc #0
          sta wtmp4+1

          sec                           ; save lower of lhs to wtmp1
          lda wtmp3
          sbc wtmp1
          lda wtmp3+1
          sbc wtmp1+1
          bpl rhs

          lda wtmp3
          sta wtmp1
          lda wtmp3+1
          sta wtmp1+1

rhs:      sec                           ; save greater of rhs to wtmp2
          lda wtmp2
          sbc wtmp4
          lda wtmp2+1
          sbc wtmp4+1
          bpl bound_x

          lda wtmp4
          sta wtmp2
          lda wtmp4+1
          sta wtmp2+1

bound_x:  lda wtmp2                     ; store bound witdh to wtmp4
          sec
          sbc wtmp1
          sta wtmp4
          lda wtmp2+1
          sbc wtmp1+1
          sta wtmp4+1

          lda bullet_attrs+Bullet::w    ; store min width in wtmp3
          clc
          adc enemy_attrs+EAttrs::w
          sta wtmp3
          lda #0
          sta wtmp3+1

          lda wtmp4
          sec
          sbc wtmp3
          lda wtmp4+1
          sbc wtmp3+1
          bmi test_y                    ; continue if negative otherwise return
          rts

test_y:   lda #0
          sta wtmp1+1
          lda bullets+Bullets::i,x
          asl                           ; mult by 8 to translate to px
          rol wtmp1+1
          asl
          rol wtmp1+1
          asl
          rol wtmp1+1

          clc                           ; y border compensation
          adc #50
          sta wtmp1
          lda wtmp1+1
          adc #0
          sta wtmp1+1

          lda wtmp1                     ; add dy
          clc
          adc bullet_attrs+Bullet::dy
          sta wtmp1
          lda wtmp1+1
          adc #0
          sta wtmp1+1

          lda wtmp1                     ; save bottom
          clc
          adc bullet_attrs+Bullet::h
          sta wtmp2
          lda wtmp1+1
          adc #0
          sta wtmp2+1

          lda enemies+Enemies::_y,y     ; get enemy y and add dy
          clc
          adc enemy_attrs+EAttrs::dy
          sta wtmp3
          lda enemies+Enemies::_y+1,y
          adc #0
          sta wtmp3+1

          lda wtmp3                     ; save bottom
          clc
          adc enemy_attrs+EAttrs::h
          sta wtmp4
          lda wtmp3+1
          adc #0
          sta wtmp4+1

          sec                           ; save lower of top to wtmp1
          lda wtmp3
          sbc wtmp1
          lda wtmp3+1
          sbc wtmp1+1
          bpl top

          lda wtmp3
          sta wtmp1
          lda wtmp3+1
          sta wtmp1+1

top:      sec                           ; save greater of top to wtmp2
          lda wtmp2
          sbc wtmp4
          lda wtmp2+1
          sbc wtmp4+1
          bpl bound_y

          lda wtmp4
          sta wtmp2
          lda wtmp4+1
          sta wtmp2+1

bound_y:  lda wtmp2                     ; store bound height to wtmp4
          sec
          sbc wtmp1
          sta wtmp4
          lda wtmp2+1
          sbc wtmp1+1
          sta wtmp4+1

          lda bullet_attrs+Bullet::h    ; store min height in wtmp3
          clc
          adc enemy_attrs+EAttrs::h
          sta wtmp3
          lda #0
          sta wtmp3+1

          lda wtmp4
          sec
          sbc wtmp3
          lda wtmp4+1
          sbc wtmp3+1

          rts
.endproc

          .rodata
          .byte 'r','o','d'
scr_rt:   .word SCREEN+ 0*40, SCREEN+ 1*40, SCREEN+ 2*40, SCREEN+ 3*40, SCREEN+ 4*40
          .word SCREEN+ 5*40, SCREEN+ 6*40, SCREEN+ 7*40, SCREEN+ 8*40, SCREEN +9*40
          .word SCREEN+10*40, SCREEN+11*40, SCREEN+12*40, SCREEN+13*40, SCREEN+14*40
          .word SCREEN+15*40, SCREEN+16*40, SCREEN+17*40, SCREEN+18*40, SCREEN+19*40
          .word SCREEN+20*40, SCREEN+21*40, SCREEN+22*40, SCREEN+23*40, SCREEN+24*40

bullet_attrs:
          .byte 0, 2, 8, 4
player_attrs:
          .byte 0,0,24,17
enemy_attrs:
          .byte 0, 1, 20, 18

          .bss
player:   .tag Player
bullets:  .tag Bullets
enemies:  .tag Enemies

          .segment "SPRITES"
sprite:   .byte %00011000, %00000000, %00000000
          .byte %00011111, %11000000, %00000000
          .byte %00010011, %10110000, %00000000
          .byte %00010011, %10001100, %00000000
          .byte %00110011, %10000011, %00000000
          .byte %00110011, %11000000, %11000000
          .byte %01110011, %11100000, %00110000
          .byte %11110011, %11111111, %11111100
          .byte %11110000, %11111111, %11111111
          .byte %11110000, %00111111, %11111110
          .byte %01110000, %00010101, %01010100
          .byte %00110000, %00101010, %10101000
          .byte %00110000, %01010101, %00010000
          .byte %00010000, %00000000, %11100000
          .byte %00010000, %11111111, %00000000
          .byte %00010001, %00000000, %00000000
          .byte %00011110, %00000000, %00000000
          .byte %00000000, %00000000, %00000000
          .byte %00000000, %00000000, %00000000
          .byte %00000000, %00000000, %00000000
          .byte %00000000, %00000000, %00000000

.align    $40
sprite2:  .byte %00000011, %11111110, %00000000
          .byte %00001100, %00000001, %10000000
          .byte %00010000, %00000000, %01000000
          .byte %00100000, %11000000, %00100000
          .byte %01000011, %01000000, %00010000
          .byte %01000100, %01000000, %00010000
          .byte %10001000, %10000000, %00010000
          .byte %10001111, %00000000, %00010000
          .byte %10000000, %00000000, %00010000
          .byte %10000000, %10000000, %00010000
          .byte %01111111, %10000000, %00010000
          .byte %00000000, %10000000, %00010000
          .byte %00100000, %10000000, %00010000
          .byte %01010000, %10000000, %00010000
          .byte %01010000, %10000000, %00010000
          .byte %01001111, %00000000, %00010000
          .byte %01000000, %00000000, %00010000
          .byte %00100000, %00000000, %00100000
          .byte %00010000, %00000000, %11000000
          .byte %00001100, %00000111, %00000000
          .byte %00000011, %11111000, %00000000
