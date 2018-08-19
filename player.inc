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

          .global init_player
          .global player_attrs
          .global player
