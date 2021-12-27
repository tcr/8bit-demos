.PHONY: all clean

all: build/main.bin

build/main.bin: src/main.asm
	mkdir -p build
	asl src/main.asm -cpu 8048 -o build/main.p
	p2bin build/main.p build/main.bin -r 1024-3071

clean:
	rm -rf build

run: build/main.bin
	mame -window -video opengl odyssey2 -cart ./build/main.bin -skip_gameinfo
