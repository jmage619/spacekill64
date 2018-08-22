; zero page
INPUT     = $02
_a        = $03
_b        = $04
_c        = $05
_d        = $06
_e        = $07
_f        = $08
x_chr     = $09
y_chr     = $0a
flags     = $0b
tmp       = $0c
scr_p     = $0d
wtmp1     = $0f
wtmp2     = $11
wtmp3     = $13
wtmp4     = $15
data_ptr  = $20

SCREEN    = $0400
SPR_P     = $07f8

sprite    = $2000
sprite2   = $2040

SCREEN2   = $2c00

CHARS     = $3800
LVL       = $4000

; system
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

KEY_PA    = $dc00
KEY_PB    = $dc01
KEY_DA    = $dc02
KEY_DB    = $dc03
KEY_INT   = $dc0d

SETLFS    = $ffba
SETNAM    = $ffbd
CHROUT    = $ffd2
LOAD      = $ffd5
