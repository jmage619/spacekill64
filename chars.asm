          .data
          .byte 0,0,0,0,0,0,0,0                   ; empty tile at $00
          .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff   ; define tile at $01

          .res $400-2*8

          ;.byte %00000000               ; define player bullet at $80
          ;.byte %00000000
          ;.byte %00111100
          ;.byte %11111111
          ;.byte %11111111
          ;.byte %00111100
          ;.byte %00000000
          ;.byte %00000000

          .byte %11111111               ; define player bullet at $80
          .byte %10000000
          .byte %10000000
          .byte %10000000
          .byte %10000000
          .byte %10000000
          .byte %10000000
          .byte %11111111

          .byte %11111111               ; define player bullet at $80
          .byte %00000001
          .byte %00000001
          .byte %00000001
          .byte %00000001
          .byte %00000001
          .byte %00000001
          .byte %11111111
