          .include "bullets.inc"

          .code
.proc     init_bullets
          lda #0
          ldx #0
next:     sta bullets+Bullets::flags,x
          inx
          cpx #8
          bne next
          rts
.endproc

          .bss
bullets:  .tag Bullets
