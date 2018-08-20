all: test.d64

test.d64: spacekill chars
	c1541 -format test,01 d64 $@ -write spacekill -write chars

spacekill: spacekill.o input.o sprites.o player.o bullets.o screen.o
	cl65 -Ln vice.txt -u __EXEHDR__ -C cl65.cfg -o $@ $^

spacekill.o: spacekill.asm input.inc sprites.inc player.inc bullets.inc screen.inc zeropage.inc sys.inc
	cl65 -g -c -t c64 -o $@ $<

chars: chars.asm
	cl65 -t c64 -C cl65.cfg -o $@ $^

bullets.o: bullets.asm bullets.inc screen.inc zeropage.inc sys.inc
	cl65 -c -t c64 -o $@ $<

player.o: player.asm player.inc screen.inc zeropage.inc sys.inc
	cl65 -c -t c64 -o $@ $<

sprites.o: sprites.asm sprites.inc
	cl65 -c -t c64 -o $@ $<

screen.o: screen.asm screen.inc zeropage.inc
	cl65 -c -t c64 -o $@ $<

input.o: input.asm input.inc zeropage.inc
	cl65 -c -t c64 -o $@ $<

clean:
	rm -f test.d64 spacekill spacekill.o player.o sprites.o input.o chars.o
