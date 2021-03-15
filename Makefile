PKG=dice.bin
SRCS=dice.asm
ASM=fasm

$(PKG): $(SRCS)
	$(ASM) $(SRCS) $(PKG)


dice.hex: $(PKG)
	xxd $< $@

clean-all: clean
	rm -f *.bin

clean:
	rm -f *.hex

run:
	bochs

