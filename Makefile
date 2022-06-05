all:
	mkdir -p build
	asl supercat.asm -cpu 6502UNDOC -relaxed -o build/prg.p -L -olist build/prg.lst
	asl header.asm -cpu 6502UNDOC -relaxed -o build/header.p

	p2bin build/header.p build/header.bin -r 0x0-0xf -l 0
	p2bin build/prg.p build/prg.bin -r 0x8000-0xffff -l 0

	cat build/header.bin \
		build/prg.bin \
		build/chr.bin > build/supercat.nes


run: all
	fceux ./build/supercat.nes

run-mame: all
	mame nes -cart ./build/supercat.nes
