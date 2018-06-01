all: test.d64

test.d64: spacekill
	c1541 -format test,01 d64 $@ -write $^

spacekill: spacekill.asm
	cl65 -u __EXEHDR__ -C cl65.cfg -o $@ $^

clean:
	rm -f test.d64 spacekill spacekill.o
