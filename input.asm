          .include "input.inc"
          .include "zeropage.inc"

SCREEN    = $0400
KEY_PA    = $dc00
KEY_PB    = $dc01
KEY_DA    = $dc02
KEY_DB    = $dc03
KEY_INT   = $dc0d

; kills kernal keyboard interrupts
          .code
.proc     init_input
          sei
          lda #$7f
          sta KEY_INT
          lda KEY_INT
          cli

          lda #0
          sta INPUT

          rts
.endproc

; fills INPUT zp bitfield starting with lsb
; 012345
; wasdkl
.proc     read_input
          lda #$ff
          sta KEY_DA
          lda #$0
          sta KEY_DB

loop:     lda #<~(1<<1)       ; enable A column
          sta KEY_PA

          lda #1<<2           ; test A
          bit KEY_PB
          bne offa

          lda INPUT           ; if pressed enable
          ora #1<<1
          sta INPUT
          jmp w

offa:     lda INPUT           ; else disable
          and #<~(1<<1)
          sta INPUT

w:        lda #$1<<1          ; test W
          bit KEY_PB
          bne offw

          lda INPUT
          ora #1
          sta INPUT
          jmp s

offw:     lda INPUT
          and #<~1
          sta INPUT

s:        lda #$1<<5          ; test S
          bit KEY_PB
          bne offs

          lda INPUT
          ora #1<<2
          sta INPUT
          jmp d

offs:     lda INPUT
          and #<~(1<<2)
          sta INPUT

d:        lda #<~(1<<2)       ; enable D column
          sta KEY_PA

          lda #$1<<2          ; test D
          bit KEY_PB
          bne offd

          lda INPUT
          ora #1<<3
          sta INPUT
          jmp k

offd:     lda INPUT
          and #<~(1<<3)
          sta INPUT

k:        lda #<~(1<<4)       ; enable K column
          sta KEY_PA

          lda #$1<<5          ; test K
          bit KEY_PB
          bne offk

          lda INPUT
          ora #1<<4
          sta INPUT
          jmp l

offk:     lda INPUT
          and #<~(1<<4)
          sta INPUT

l:        lda #<~(1<<5)       ; enable L column
          sta KEY_PA

          lda #$1<<2          ; test L
          bit KEY_PB
          bne offl

          lda INPUT
          ora #1<<5
          sta INPUT
          jmp loop

offl:     lda INPUT
          and #<~(1<<5)
          sta INPUT

          rts
.endproc