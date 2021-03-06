all: test.d64

test.d64: spacekill chars level sprites
	c1541 -format test,01 d64 $@ -write spacekill -write chars -write sprites -write level

spacekill: spacekill.o input.o player.o enemies.o bullets.o screen.o
	cl65 -Ln vice.txt -u __EXEHDR__ -C cl65.cfg -o $@ $^

spacekill.o: spacekill.asm input.inc globals.inc player.inc enemies.inc bullets.inc screen.inc
	cl65 -g -c -t c64 -o $@ $<

chars: chars.asm
	cl65 -t c64 -C cl65.cfg -o $@ $^

sprites: sprites.asm
	cl65 -t c64 -C cl65.cfg -o $@ $^

level: level.asm
	cl65 -t c64 -C cl65.cfg -o $@ $^

bullets.o: bullets.asm bullets.inc screen.inc globals.inc
	cl65 -c -t c64 -o $@ $<

enemies.o: enemies.asm enemies.inc screen.inc globals.inc
	cl65 -c -t c64 -o $@ $<

player.o: player.asm player.inc screen.inc globals.inc
	cl65 -c -t c64 -o $@ $<

screen.o: screen.asm screen.inc globals.inc
	cl65 -c -t c64 -o $@ $<

input.o: input.asm input.inc globals.inc
	cl65 -c -t c64 -o $@ $<

clean:
	rm -f test.d64 spacekill spacekill.o player.o enemies.o bullets.o screen.o input.o chars.o level.o sprites.o chars level sprites
