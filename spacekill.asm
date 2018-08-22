          .include "globals.inc"
          .include "input.inc"
          .include "screen.inc"
          .include "player.inc"
          .include "enemies.inc"
          .include "bullets.inc"

SDLY      = 8
SPEED     = 2

          .code
          ; custom char set loaded into $3800
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

          ; sprites loaded into $2000
          lda #7
          ldx #<spr_fname
          ldy #>spr_fname
          jsr SETNAM
          lda #1
          ldx #8
          ldy #0
          jsr SETLFS
          ldx #<sprite
          ldy #>sprite
          lda #0
          jsr LOAD

          ; level loaded into $4000
          lda #5
          ldx #<lvl_fname
          ldy #>lvl_fname
          jsr SETNAM
          lda #1
          ldx #8
          ldy #0
          jsr SETLFS
          ldx #<LVL
          ldy #>LVL
          lda #0
          jsr LOAD

          lda #<LVL
          sta data_ptr
          lda #>LVL
          sta data_ptr+1

          lda VIC_CTL         ; point to char set
          and #$f0
          ora #CHR_PG
          sta VIC_CTL

          lda #$0b            ; gray border
          sta BDR_CO          

          lda #$00            ; black background
          sta BKG_CO

          jsr clr_screen      ; clear screen
b1:       jsr clr_screen2     ; clear screen


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

          lda #0
          sta fcnt
          lda #1
          sta sflag
          jsr fill_scrcol2

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
          sbc #SPEED
          sta player+Player::_x
          lda player+Player::_x+1
          sbc #0
          sta player+Player::_x+1

check_R:  lda #1<<3
          bit INPUT
          beq check_U
          lda player+Player::_x
          clc
          adc #SPEED
          sta player+Player::_x
          lda player+Player::_x+1
          adc #0
          sta player+Player::_x+1

check_U:  lda #1
          bit INPUT
          beq check_D
          lda player+Player::_y
          sec
          sbc #SPEED
          sta player+Player::_y

check_D:  lda #1<<2
          bit INPUT
          beq upd_pl
          lda player+Player::_y
          clc
          adc #SPEED
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

update:   ldx fcnt
          lda sflag
          bne shs2
          jsr shift_scr
          jmp inc_frm

shs2:     jsr shift_scr2

inc_frm:  inc fcnt
          lda #SDLY
          cmp fcnt
          beq ncol
          jmp upd_bul

ncol:     lda #0
          sta fcnt
          lda data_ptr
          clc
          adc #25
          sta data_ptr
          lda data_ptr+1
          adc #0
          sta data_ptr+1

          lda sflag
          bne sw2

          lda VIC_CTL
          and #$0f
          ora #SCR1_PG
          sta VIC_CTL
          jsr fill_scrcol2
          lda #1
          sta sflag
          jmp upd_bul

sw2:      lda VIC_CTL
          and #$0f
          ora #SCR2_PG
          sta VIC_CTL
          jsr fill_scrcol
          lda #0
          sta sflag

upd_bul:  jsr update_bullets

          jmp mloop

          .data
chr_fname:
          .byte "chars"
spr_fname:
          .byte "sprites"
lvl_fname:
          .byte "level"
