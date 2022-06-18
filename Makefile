all: img/HelloWorld.chr
	mkdir -p build
	asl src/stableframe.asm -cpu 6502UNDOC -relaxed -o build/prg.p -L -olist build/prg.lst
	asl src/targets/header.asm -cpu 6502UNDOC -relaxed -o build/header.p
	asl src/targets/chr.asm -cpu 6502UNDOC -relaxed -o build/chr.p

	p2bin build/header.p build/header.bin -r 0x0-0xf -l 0
	p2bin build/chr.p build/chr.bin -r 0x0-0x1fff -l 0

	p2bin build/prg.p build/prg.bin -r 0x8000-0xffff -l 0

	cat build/header.bin \
		build/prg.bin \
		build/chr.bin > build/stableframe.nes

run: all
	fceux ./build/stableframe.nes

run-mame: all
	mame nes -cart ./build/stableframe.nes

img/HelloWorld.chr: img/HelloWorld.png
	pixconsola encode $< --format nes -o $@
