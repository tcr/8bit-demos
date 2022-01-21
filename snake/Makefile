.PHONY: all clean

all: build/main.bin

build/main.bin: src/main.asm
	mkdir -p build
	asl src/main.asm -cpu 8048 -o build/main.p -relaxed -L -olist build/paxconsola.lst
	p2bin build/main.p build/main.bin -r 1024-3071

clean:
	rm -rf build

run: build/main.bin
	mame -window -video opengl odyssey2 -cart ./build/main.bin -skip_gameinfo -prescale 2 -nomax -resolution0 1024x768

debug: build/main.bin
	mame -window -video opengl odyssey2 -cart ./build/main.bin -skip_gameinfo -prescale 2 -nomax -resolution0 1024x768 -debug
