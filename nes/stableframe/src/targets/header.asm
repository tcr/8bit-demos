  org $0000

; this header is to set up a NROM mapper 000 with fixed banks (no bank switching)
  byt 'N', 'E', 'S', $1A   ; these bytes always start off an ines file
  byt $02                   ; PRG size in 16k units
  byt $01                   ; CHR size in 8k units


MAPPER = 0

;============================================================================================
; iNES flag 6
; 7654 3210
; |||| ||||
; |||| |||+- Mirroring: 0: horizontal (vertical arrangement) (CIRAM A10 = PPU A11)
; |||| |||              1: vertical (horizontal arrangement) (CIRAM A10 = PPU A10)
; |||| ||+-- 1: Cartridge contains battery-backed PRG RAM ($6000-7FFF) or other persistent memory
; |||| |+--- 1: 512-byte trainer at $7000-$71FF (stored before PRG data)
; |||| +---- 1: Ignore mirroring control or above mirroring bit; instead provide four-screen VRAM
; |||| 
; ++++----- Lower nybble of mapper number
;============================================================================================
  byt ((MAPPER & %1111) << 4) | %0000
  byt (MAPPER & %11110000)
  byt $0, $0, $0, $0, $0
; this is about as basic as the header gets.  
