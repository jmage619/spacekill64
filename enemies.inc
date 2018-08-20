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

          .global enemy_attrs
          .global enemies
