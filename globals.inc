; literals
CHR_PG    = 14
SCR1_PG   = $10
SCR2_PG   = $d0

; zero page
tmp       = $02                         ; zp for main
flags     = $03
hit_dly   = $04

_a        = $10                         ; zp for leaf routines
_b        = $11
_c        = $12
_d        = $13
_e        = $14
_f        = $15
_g        = $16

wa        = $20                         ; word size zp for leaf routines
wb        = $22
wc        = $24
wd        = $26

INPUT     = $30                         ; zp for input

fcnt      = $40                         ; zp for screen
scr_flag  = $41
scr_p     = $48
data_ptr  = $4b

; vic stuff
SCREEN    = $0400
SPR_P     = $07f8

sprite    = $2000
sprite2   = $2040

SCREEN2   = $3400
SPR_P2    = $37f8
CHARS     = $3800

BULCHR    = $3c00

; data
LVL       = $4000

; system
SCR_CO    = $d800
RST_LN    = $d012
VIC_MOD   = $d016
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
