          .include "input.inc"
          .include "zeropage.inc"

CHROUT    = $ffd2

SCREEN    = $0400
SPR_P     = $07f8
SCR_CO    = $d800
RST_LN    = $d012
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
x_chr     = $03
y_chr     = $04
flags     = $05
tmp       = $06
scr_p     = $07
wtmp1     = $09
wtmp2     = $0b
wtmp3     = $0d
wtmp4     = $0f

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

.scope    Enemy
dx        = 0
dy        = 1
w         = 2
h         = 3
.endscope

.struct   Enemies
id        .word 8
_x        .word 8
_y        .word 8
.endstruct

          .code

          lda #$0b            ; gray border
          sta BDR_CO          

          lda #$00            ; black background
          sta BKG_CO

          lda #$93            ; clear screen
          jsr CHROUT

          lda #$a0
          sta SCREEN + 5 * 40 + 10

          lda #0
          sta flags
          jsr init_input

          lda #<(sprite / 64) ; define sprite
          sta SPR_P
          lda SPR_EN
          ora #1
          sta SPR_EN
          lda #1
          sta SPR_CO
          lda #31
          sta SPR_X
          lda #57
          sta SPR_Y

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

          jsr init_bullets

          ldy #0              ; init position
mloop:    lda #$ff            ; wait until raster hit bottom border
l1:       cmp RST_LN
          bne l1
                              ; display should be updated first as much as possible

          jsr read_input      ; get input

                              ; update sprite pos
          lda #1<<1           ; check L
          bit INPUT
          beq check_R
          lda SPR_X
          sec
          sbc #speed
          sta SPR_X
          bcs check_R         ; if borrow, clear upper bit of SPR_X

          lda SPR_MX
          and #<~1
          sta SPR_MX

check_R:  lda #1<<3
          bit INPUT
          beq check_U
          lda SPR_X
          clc
          adc #speed
          sta SPR_X
          bcc check_U         ; if carry, set upper bit of SPR_X

          lda SPR_MX
          ora #1
          sta SPR_MX

check_U:  lda #1
          bit INPUT
          beq check_D
          lda SPR_Y
          sec
          sbc #speed
          sta SPR_Y

check_D:  lda #1<<2
          bit INPUT
          beq check_K
          lda SPR_Y
          clc
          adc #speed
          sta SPR_Y

check_K:  lda #1<<4           ; shoot if K pressed
          bit INPUT
          beq fire_off

          lda #1              ; only fire if not pressed previously
          bit flags
          bne fire_on
          jsr create_bullet
fire_on:  lda flags           ; set pressed
          ora #1
          sta flags
          jmp chk_hit

fire_off: lda flags           ; clear pressed
          and #<~1
          sta flags

chk_hit:  lda #1              ; check if sprite hit background
          bit SPR_CLB
          beq no_hit

          lda #2              ; color red if hit
          sta SPR_CO
          jmp update

no_hit:   lda #1              ; otherwise color white
          sta SPR_CO

;burn:     ldx #13             ; enough cycles for raster to pass
;l3:       dex                 ; line $ff (63 cycles a line)
;          bne l3

update:   jsr update_bullets
          jmp mloop
          .byte 'e','n','d'

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
          adc #3              ; correct x pos rel to sprite
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
          lda #$20                      ; blank out prev on screen
          sta (scr_p),y

          ;iny
          ;cpy #40
          ;beq disable

          tya
          sta bullets+Bullets::j,x      ; update bullet on screen
          lda #$a0
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

set:      sta tmp                       ; save sprite flag for max x bit
          ora SPR_EN                    ; define enemy sprite
          sta SPR_EN
          tya
          sta enemies+Enemies::id,x     ; save offset
          lda #<(sprite2 / 64)
          sta SPR_P,y
          lda #1
          sta SPR_CO,y
          tya                           ; sprite x,y are in pairs so
          asl                           ; multiply by 2 for correct offsets
          tay
          lda enemies+Enemies::_x,x
          sta SPR_X,y
          lda enemies+Enemies::_x+1,x
          beq get_y                     ; test if sprite max x bit should be set

          lda SPR_MX
          ora tmp
          sta SPR_MX

get_y:    lda enemies+Enemies::_y,x
          sta SPR_Y,y

          jmp return

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
          adc enemy_attrs+Enemy::dx
          sta wtmp3
          lda enemies+Enemies::_x+1,y
          adc #0
          sta wtmp3+1

          lda wtmp3                     ; save rhs
          clc
          adc enemy_attrs+Enemy::w
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
          adc enemy_attrs+Enemy::w
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
          adc enemy_attrs+Enemy::dy
          sta wtmp3
          lda enemies+Enemies::_y+1,y
          adc #0
          sta wtmp3+1

          lda wtmp3                     ; save bottom
          clc
          adc enemy_attrs+Enemy::h
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
          adc enemy_attrs+Enemy::h
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
enemy_attrs:
          .byte 0, 1, 20, 18

          .bss
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
