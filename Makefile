all: test.d64

test.d64: spacekill chars
	c1541 -format test,01 d64 $@ -write spacekill -write chars

spacekill: spacekill.o input.o
	cl65 -Ln vice.txt -u __EXEHDR__ -C cl65.cfg -o $@ $^

spacekill.o: spacekill.asm input.inc zeropage.inc
	cl65 -g -c -t c64 -o $@ $<

chars: chars.asm
	cl65 -t c64 -C cl65.cfg -o $@ $^

input.o: input.asm input.inc zeropage.inc
	cl65 -c -t c64 -o $@ $<

clean:
	rm -f test.d64 spacekill spacekill.o input.o
