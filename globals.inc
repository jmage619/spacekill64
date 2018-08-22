; zero page
; zp for main
tmp       = $02
flags     = $03

; zp for leaf routines
_a        = $10
_b        = $11
_c        = $12
_d        = $13
_e        = $14
_f        = $15

; word size zp for leaf routines
wtmp1     = $20
wtmp2     = $22
wtmp3     = $24
wtmp4     = $26

; zp for input
INPUT     = $30

; zp for screen
scr_p     = $40
data_ptr  = $42


; vic stuff
SCREEN    = $0400
SPR_P     = $07f8

sprite    = $2000
sprite2   = $2040

SCREEN2   = $2c00

CHARS     = $3800

; data
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
