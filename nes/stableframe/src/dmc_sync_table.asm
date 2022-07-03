; python gen_dmc_sync.py 1038 > src/dmc_sync_table.asm

    align 256
dmc_sync_1_2:
    byt $00   ; index $0 => [0, 428, 428, 128, 54] = 1038
    byt $02   ; index $1 => [2, 428, 340, 214, 54] = 1038
    byt $00   ; index $2 => [4, 428, 428, 106, 72] = 1038
    byt $03   ; index $3 => [6, 428, 320, 142, 142] = 1038
    byt $02   ; index $4 => [8, 428, 340, 190, 72] = 1038
    byt $03   ; index $5 => [10, 428, 320, 226, 54] = 1038
    byt $11   ; index $6 => [12, 380, 380, 160, 106] = 1038
    byt $00   ; index $7 => [14, 428, 428, 84, 84] = 1038
    byt $01   ; index $8 => [16, 428, 380, 160, 54] = 1038
    byt $01   ; index $9 => [18, 428, 380, 128, 84] = 1038
    byt $03   ; index $a => [20, 428, 320, 142, 128] = 1038
    byt $00   ; index $b => [22, 428, 428, 106, 54] = 1038
    byt $03   ; index $c => [24, 428, 320, 160, 106] = 1038
    byt $00   ; index $d => [26, 428, 428, 84, 72] = 1038
    byt $03   ; index $e => [28, 428, 320, 190, 72] = 1038
    byt $01   ; index $f => [30, 428, 380, 128, 72] = 1038
    byt $12   ; index $10 => [32, 380, 340, 214, 72] = 1038
    byt $01   ; index $11 => [34, 428, 380, 142, 54] = 1038
    byt $02   ; index $12 => [36, 428, 340, 128, 106] = 1038
    byt $00   ; index $13 => [38, 428, 428, 72, 72] = 1038
    byt $01   ; index $14 => [40, 428, 380, 106, 84] = 1038
    byt $03   ; index $15 => [42, 428, 320, 142, 106] = 1038
    byt $00   ; index $16 => [44, 428, 428, 84, 54] = 1038
    byt $03   ; index $17 => [46, 428, 320, 190, 54] = 1038
    byt $01   ; index $18 => [48, 428, 380, 128, 54] = 1038
    byt $04   ; index $19 => [50, 428, 286, 190, 84] = 1038
    byt $01   ; index $1a => [52, 428, 380, 106, 72] = 1038
    byt $04   ; index $1b => [54, 428, 286, 142, 128] = 1038
    byt $00   ; index $1c => [56, 428, 428, 72, 54] = 1038
    byt $02   ; index $1d => [58, 428, 340, 128, 84] = 1038
    byt $05   ; index $1e => [60, 428, 254, 190, 106] = 1038
    byt $01   ; index $1f => [62, 428, 380, 84, 84] = 1038
    byt $03   ; index $20 => [64, 428, 320, 142, 84] = 1038
    byt $06   ; index $21 => [66, 428, 226, 190, 128] = 1038
    byt $04   ; index $22 => [68, 428, 286, 128, 128] = 1038
    byt $01   ; index $23 => [70, 428, 380, 106, 54] = 1038
    byt $05   ; index $24 => [72, 428, 254, 142, 142] = 1038
    byt $00   ; index $25 => [74, 428, 428, 54, 54] = 1038
    byt $03   ; index $26 => [76, 428, 320, 160, 54] = 1038
    byt $03   ; index $27 => [78, 428, 320, 128, 84] = 1038
    byt $02   ; index $28 => [80, 428, 340, 106, 84] = 1038
    byt $05   ; index $29 => [82, 428, 254, 190, 84] = 1038
    byt $12   ; index $2a => [84, 380, 340, 128, 106] = 1038
    byt $01   ; index $2b => [86, 428, 380, 72, 72] = 1038
    byt $02   ; index $2c => [88, 428, 340, 128, 54] = 1038
    byt $03   ; index $2d => [90, 428, 320, 128, 72] = 1038
    byt $01   ; index $2e => [92, 428, 380, 84, 54] = 1038
    byt $03   ; index $2f => [94, 428, 320, 142, 54] = 1038
    byt $06   ; index $30 => [96, 428, 226, 160, 128] = 1038
    byt $04   ; index $31 => [98, 428, 286, 142, 84] = 1038
    byt $03   ; index $32 => [100, 428, 320, 106, 84] = 1038
    byt $02   ; index $33 => [102, 428, 340, 84, 84] = 1038
    byt $01   ; index $34 => [104, 428, 380, 72, 54] = 1038
    byt $12   ; index $35 => [106, 380, 340, 128, 84] = 1038
    byt $03   ; index $36 => [108, 428, 320, 128, 54] = 1038
    byt $02   ; index $37 => [110, 428, 340, 106, 54] = 1038
    byt $03   ; index $38 => [112, 428, 320, 106, 72] = 1038
    byt $02   ; index $39 => [114, 428, 340, 84, 72] = 1038
    byt $06   ; index $3a => [116, 428, 226, 214, 54] = 1038
    byt $06   ; index $3b => [118, 428, 226, 160, 106] = 1038
    byt $15   ; index $3c => [120, 380, 254, 142, 142] = 1038
    byt $01   ; index $3d => [122, 428, 380, 54, 54] = 1038
    byt $04   ; index $3e => [124, 428, 286, 128, 72] = 1038
    byt $02   ; index $3f => [126, 428, 340, 72, 72] = 1038
    byt $04   ; index $40 => [128, 428, 286, 142, 54] = 1038
    byt $03   ; index $41 => [130, 428, 320, 106, 54] = 1038
    byt $02   ; index $42 => [132, 428, 340, 84, 54] = 1038
    byt $03   ; index $43 => [134, 428, 320, 84, 72] = 1038
    byt $06   ; index $44 => [136, 428, 226, 142, 106] = 1038
    byt $13   ; index $45 => [138, 380, 320, 128, 72] = 1038
    byt $06   ; index $46 => [140, 428, 226, 190, 54] = 1038
    byt $04   ; index $47 => [142, 428, 286, 128, 54] = 1038
    byt $02   ; index $48 => [144, 428, 340, 72, 54] = 1038
    byt $03   ; index $49 => [146, 428, 320, 72, 72] = 1038
    byt $07   ; index $4a => [148, 428, 214, 142, 106] = 1038
    byt $06   ; index $4b => [150, 428, 226, 128, 106] = 1038
    byt $03   ; index $4c => [152, 428, 320, 84, 54] = 1038
    byt $08   ; index $4d => [154, 428, 190, 160, 106] = 1038
    byt $04   ; index $4e => [156, 428, 286, 84, 84] = 1038
    byt $06   ; index $4f => [158, 428, 226, 142, 84] = 1038
    byt $05   ; index $50 => [160, 428, 254, 142, 54] = 1038
    byt $02   ; index $51 => [162, 428, 340, 54, 54] = 1038
    byt $03   ; index $52 => [164, 428, 320, 72, 54] = 1038
    byt $05   ; index $53 => [166, 428, 254, 106, 84] = 1038
    byt $04   ; index $54 => [168, 428, 286, 84, 72] = 1038
    byt $06   ; index $55 => [170, 428, 226, 160, 54] = 1038
    byt $06   ; index $56 => [172, 428, 226, 128, 84] = 1038
    byt $05   ; index $57 => [174, 428, 254, 128, 54] = 1038
    byt $08   ; index $58 => [176, 428, 190, 190, 54] = 1038
    byt $05   ; index $59 => [178, 428, 254, 106, 72] = 1038
    byt $04   ; index $5a => [180, 428, 286, 72, 72] = 1038
    byt $03   ; index $5b => [182, 428, 320, 54, 54] = 1038
    byt $06   ; index $5c => [184, 428, 226, 128, 72] = 1038
    byt $04   ; index $5d => [186, 428, 286, 84, 54] = 1038
    byt $05   ; index $5e => [188, 428, 254, 84, 84] = 1038
    byt $14   ; index $5f => [190, 380, 286, 128, 54] = 1038
    byt $12   ; index $60 => [192, 380, 340, 72, 54] = 1038
    byt $06   ; index $61 => [194, 428, 226, 106, 84] = 1038
    byt $05   ; index $62 => [196, 428, 254, 106, 54] = 1038
    byt $04   ; index $63 => [198, 428, 286, 72, 54] = 1038
    byt $05   ; index $64 => [200, 428, 254, 84, 72] = 1038
    byt $06   ; index $65 => [202, 428, 226, 128, 54] = 1038
    byt $14   ; index $66 => [204, 380, 286, 84, 84] = 1038
    byt $06   ; index $67 => [206, 428, 226, 106, 72] = 1038
    byt $08   ; index $68 => [208, 428, 190, 128, 84] = 1038
    byt $12   ; index $69 => [210, 380, 340, 54, 54] = 1038
    byt $05   ; index $6a => [212, 428, 254, 72, 72] = 1038
    byt $07   ; index $6b => [214, 428, 214, 128, 54] = 1038
    byt $04   ; index $6c => [216, 428, 286, 54, 54] = 1038
    byt $05   ; index $6d => [218, 428, 254, 84, 54] = 1038
    byt $08   ; index $6e => [220, 428, 190, 128, 72] = 1038
    byt $15   ; index $6f => [222, 380, 254, 128, 54] = 1038
    byt $06   ; index $70 => [224, 428, 226, 106, 54] = 1038
    byt $0b   ; index $71 => [226, 428, 128, 128, 128] = 1038
    byt $06   ; index $72 => [228, 428, 226, 84, 72] = 1038
    byt $05   ; index $73 => [230, 428, 254, 72, 54] = 1038
    byt $16   ; index $74 => [232, 380, 226, 128, 72] = 1038
    byt $0a   ; index $75 => [234, 428, 142, 128, 106] = 1038
    byt $07   ; index $76 => [236, 428, 214, 106, 54] = 1038
    byt $08   ; index $77 => [238, 428, 190, 128, 54] = 1038
    byt $06   ; index $78 => [240, 428, 226, 72, 72] = 1038
    byt $08   ; index $79 => [242, 428, 190, 106, 72] = 1038
    byt $15   ; index $7a => [244, 380, 254, 106, 54] = 1038
    byt $06   ; index $7b => [246, 428, 226, 84, 54] = 1038
    byt $05   ; index $7c => [248, 428, 254, 54, 54] = 1038
    byt $09   ; index $7d => [250, 428, 160, 128, 72] = 1038
    byt $07   ; index $7e => [252, 428, 214, 72, 72] = 1038
    byt $09   ; index $7f => [254, 428, 160, 142, 54] = 1038
    byt $0a   ; index $80 => [256, 428, 142, 128, 84] = 1038
    byt $06   ; index $81 => [258, 428, 226, 72, 54] = 1038
    byt $08   ; index $82 => [260, 428, 190, 106, 54] = 1038
    byt $17   ; index $83 => [262, 380, 214, 128, 54] = 1038
    byt $08   ; index $84 => [264, 428, 190, 84, 72] = 1038
    byt $15   ; index $85 => [266, 380, 254, 84, 54] = 1038
    byt $09   ; index $86 => [268, 428, 160, 128, 54] = 1038
    byt $07   ; index $87 => [270, 428, 214, 72, 54] = 1038
    byt $09   ; index $88 => [272, 428, 160, 106, 72] = 1038
    byt $1b   ; index $89 => [274, 380, 128, 128, 128] = 1038
    byt $06   ; index $8a => [276, 428, 226, 54, 54] = 1038
    byt $0a   ; index $8b => [278, 428, 142, 106, 84] = 1038
    byt $36   ; index $8c => [280, 320, 226, 128, 84] = 1038
    byt $08   ; index $8d => [282, 428, 190, 84, 54] = 1038
    byt $17   ; index $8e => [284, 380, 214, 106, 54] = 1038
    byt $0a   ; index $8f => [286, 428, 142, 128, 54] = 1038
    byt $07   ; index $90 => [288, 428, 214, 54, 54] = 1038
    byt $09   ; index $91 => [290, 428, 160, 106, 54] = 1038
    byt $0b   ; index $92 => [292, 428, 128, 106, 84] = 1038
    byt $08   ; index $93 => [294, 428, 190, 72, 54] = 1038
    byt $15   ; index $94 => [296, 380, 254, 54, 54] = 1038
    byt $19   ; index $95 => [298, 380, 160, 128, 72] = 1038
    byt $0a   ; index $96 => [300, 428, 142, 84, 84] = 1038
    byt $19   ; index $97 => [302, 380, 160, 142, 54] = 1038
    byt $0b   ; index $98 => [304, 428, 128, 106, 72] = 1038
    byt $09   ; index $99 => [306, 428, 160, 72, 72] = 1038
    byt $0a   ; index $9a => [308, 428, 142, 106, 54] = 1038
    byt $36   ; index $9b => [310, 320, 226, 128, 54] = 1038
    byt $08   ; index $9c => [312, 428, 190, 54, 54] = 1038
    byt $0b   ; index $9d => [314, 428, 128, 84, 84] = 1038
    byt $19   ; index $9e => [316, 380, 160, 128, 54] = 1038
    byt $17   ; index $9f => [318, 380, 214, 72, 54] = 1038
    byt $19   ; index $a0 => [320, 380, 160, 106, 72] = 1038
    byt $0b   ; index $a1 => [322, 428, 128, 106, 54] = 1038
    byt $09   ; index $a2 => [324, 428, 160, 72, 54] = 1038
    byt $0b   ; index $a3 => [326, 428, 128, 84, 72] = 1038
    byt $26   ; index $a4 => [328, 340, 226, 72, 72] = 1038
    byt $0a   ; index $a5 => [330, 428, 142, 84, 54] = 1038
    byt $36   ; index $a6 => [332, 320, 226, 106, 54] = 1038
    byt $1a   ; index $a7 => [334, 380, 142, 128, 54] = 1038
    byt $0c   ; index $a8 => [336, 428, 106, 84, 84] = 1038
    byt $0b   ; index $a9 => [338, 428, 128, 72, 72] = 1038
    byt $1b   ; index $aa => [340, 380, 128, 106, 84] = 1038
    byt $09   ; index $ab => [342, 428, 160, 54, 54] = 1038
    byt $0b   ; index $ac => [344, 428, 128, 84, 54] = 1038
    byt $26   ; index $ad => [346, 340, 226, 72, 54] = 1038
    byt $0c   ; index $ae => [348, 428, 106, 84, 72] = 1038
    byt $38   ; index $af => [350, 320, 190, 106, 72] = 1038
    byt $1b   ; index $b0 => [352, 380, 128, 106, 72] = 1038
    byt $19   ; index $b1 => [354, 380, 160, 72, 72] = 1038
    byt $0b   ; index $b2 => [356, 428, 128, 72, 54] = 1038
    byt $0d   ; index $b3 => [358, 428, 84, 84, 84] = 1038
    byt $0a   ; index $b4 => [360, 428, 142, 54, 54] = 1038
    byt $1b   ; index $b5 => [362, 380, 128, 84, 84] = 1038
    byt $26   ; index $b6 => [364, 340, 226, 54, 54] = 1038
    byt $0c   ; index $b7 => [366, 428, 106, 84, 54] = 1038
    byt $38   ; index $b8 => [368, 320, 190, 106, 54] = 1038
    byt $0d   ; index $b9 => [370, 428, 84, 84, 72] = 1038
    byt $19   ; index $ba => [372, 380, 160, 72, 54] = 1038
    byt $0b   ; index $bb => [374, 428, 128, 54, 54] = 1038
    byt $27   ; index $bc => [376, 340, 214, 54, 54] = 1038
    byt $0c   ; index $bd => [378, 428, 106, 72, 54] = 1038
    byt $2b   ; index $be => [380, 340, 128, 106, 84] = 1038
    byt $0d   ; index $bf => [382, 428, 84, 72, 72] = 1038
    byt $1c   ; index $c0 => [384, 380, 106, 84, 84] = 1038
    byt $1b   ; index $c1 => [386, 380, 128, 72, 72] = 1038
    byt $0d   ; index $c2 => [388, 428, 84, 84, 54] = 1038
    byt $19   ; index $c3 => [390, 380, 160, 54, 54] = 1038
    byt $1b   ; index $c4 => [392, 380, 128, 84, 54] = 1038
    byt $0e   ; index $c5 => [394, 428, 72, 72, 72] = 1038
    byt $0c   ; index $c6 => [396, 428, 106, 54, 54] = 1038
    byt $39   ; index $c7 => [398, 320, 160, 106, 54] = 1038
    byt $0d   ; index $c8 => [400, 428, 84, 72, 54] = 1038
    byt $2b   ; index $c9 => [402, 340, 128, 84, 84] = 1038
    byt $1b   ; index $ca => [404, 380, 128, 72, 54] = 1038
    byt $1d   ; index $cb => [406, 380, 84, 84, 84] = 1038
    byt $1a   ; index $cc => [408, 380, 142, 54, 54] = 1038
    byt $2b   ; index $cd => [410, 340, 128, 106, 54] = 1038
    byt $0e   ; index $ce => [412, 428, 72, 72, 54] = 1038
    byt $1c   ; index $cf => [414, 380, 106, 84, 54] = 1038
    byt $3a   ; index $d0 => [416, 320, 142, 106, 54] = 1038
    byt $0d   ; index $d1 => [418, 428, 84, 54, 54] = 1038
    byt $38   ; index $d2 => [420, 320, 190, 54, 54] = 1038
    byt $1b   ; index $d3 => [422, 380, 128, 54, 54] = 1038
    byt $2c   ; index $d4 => [424, 340, 106, 84, 84] = 1038
    byt $1c   ; index $d5 => [426, 380, 106, 72, 54] = 1038
    byt $4a   ; index $d6 => [428, 286, 142, 128, 54] = 1038
    byt $0e   ; index $d7 => [430, 428, 72, 54, 54] = 1038

    align 256
dmc_sync_3_4:
    byt $bf   ; index $0 => [0, 428, 428, 128, 54] = 1038
    byt $7f   ; index $1 => [2, 428, 340, 214, 54] = 1038
    byt $ce   ; index $2 => [4, 428, 428, 106, 72] = 1038
    byt $aa   ; index $3 => [6, 428, 320, 142, 142] = 1038
    byt $8e   ; index $4 => [8, 428, 340, 190, 72] = 1038
    byt $6f   ; index $5 => [10, 428, 320, 226, 54] = 1038
    byt $9c   ; index $6 => [12, 380, 380, 160, 106] = 1038
    byt $dd   ; index $7 => [14, 428, 428, 84, 84] = 1038
    byt $9f   ; index $8 => [16, 428, 380, 160, 54] = 1038
    byt $bd   ; index $9 => [18, 428, 380, 128, 84] = 1038
    byt $ab   ; index $a => [20, 428, 320, 142, 128] = 1038
    byt $cf   ; index $b => [22, 428, 428, 106, 54] = 1038
    byt $9c   ; index $c => [24, 428, 320, 160, 106] = 1038
    byt $de   ; index $d => [26, 428, 428, 84, 72] = 1038
    byt $8e   ; index $e => [28, 428, 320, 190, 72] = 1038
    byt $be   ; index $f => [30, 428, 380, 128, 72] = 1038
    byt $7e   ; index $10 => [32, 380, 340, 214, 72] = 1038
    byt $af   ; index $11 => [34, 428, 380, 142, 54] = 1038
    byt $bc   ; index $12 => [36, 428, 340, 128, 106] = 1038
    byt $ee   ; index $13 => [38, 428, 428, 72, 72] = 1038
    byt $cd   ; index $14 => [40, 428, 380, 106, 84] = 1038
    byt $ac   ; index $15 => [42, 428, 320, 142, 106] = 1038
    byt $df   ; index $16 => [44, 428, 428, 84, 54] = 1038
    byt $8f   ; index $17 => [46, 428, 320, 190, 54] = 1038
    byt $bf   ; index $18 => [48, 428, 380, 128, 54] = 1038
    byt $8d   ; index $19 => [50, 428, 286, 190, 84] = 1038
    byt $ce   ; index $1a => [52, 428, 380, 106, 72] = 1038
    byt $ab   ; index $1b => [54, 428, 286, 142, 128] = 1038
    byt $ef   ; index $1c => [56, 428, 428, 72, 54] = 1038
    byt $bd   ; index $1d => [58, 428, 340, 128, 84] = 1038
    byt $8c   ; index $1e => [60, 428, 254, 190, 106] = 1038
    byt $dd   ; index $1f => [62, 428, 380, 84, 84] = 1038
    byt $ad   ; index $20 => [64, 428, 320, 142, 84] = 1038
    byt $8b   ; index $21 => [66, 428, 226, 190, 128] = 1038
    byt $bb   ; index $22 => [68, 428, 286, 128, 128] = 1038
    byt $cf   ; index $23 => [70, 428, 380, 106, 54] = 1038
    byt $aa   ; index $24 => [72, 428, 254, 142, 142] = 1038
    byt $ff   ; index $25 => [74, 428, 428, 54, 54] = 1038
    byt $9f   ; index $26 => [76, 428, 320, 160, 54] = 1038
    byt $bd   ; index $27 => [78, 428, 320, 128, 84] = 1038
    byt $cd   ; index $28 => [80, 428, 340, 106, 84] = 1038
    byt $8d   ; index $29 => [82, 428, 254, 190, 84] = 1038
    byt $bc   ; index $2a => [84, 380, 340, 128, 106] = 1038
    byt $ee   ; index $2b => [86, 428, 380, 72, 72] = 1038
    byt $bf   ; index $2c => [88, 428, 340, 128, 54] = 1038
    byt $be   ; index $2d => [90, 428, 320, 128, 72] = 1038
    byt $df   ; index $2e => [92, 428, 380, 84, 54] = 1038
    byt $af   ; index $2f => [94, 428, 320, 142, 54] = 1038
    byt $9b   ; index $30 => [96, 428, 226, 160, 128] = 1038
    byt $ad   ; index $31 => [98, 428, 286, 142, 84] = 1038
    byt $cd   ; index $32 => [100, 428, 320, 106, 84] = 1038
    byt $dd   ; index $33 => [102, 428, 340, 84, 84] = 1038
    byt $ef   ; index $34 => [104, 428, 380, 72, 54] = 1038
    byt $bd   ; index $35 => [106, 380, 340, 128, 84] = 1038
    byt $bf   ; index $36 => [108, 428, 320, 128, 54] = 1038
    byt $cf   ; index $37 => [110, 428, 340, 106, 54] = 1038
    byt $ce   ; index $38 => [112, 428, 320, 106, 72] = 1038
    byt $de   ; index $39 => [114, 428, 340, 84, 72] = 1038
    byt $7f   ; index $3a => [116, 428, 226, 214, 54] = 1038
    byt $9c   ; index $3b => [118, 428, 226, 160, 106] = 1038
    byt $aa   ; index $3c => [120, 380, 254, 142, 142] = 1038
    byt $ff   ; index $3d => [122, 428, 380, 54, 54] = 1038
    byt $be   ; index $3e => [124, 428, 286, 128, 72] = 1038
    byt $ee   ; index $3f => [126, 428, 340, 72, 72] = 1038
    byt $af   ; index $40 => [128, 428, 286, 142, 54] = 1038
    byt $cf   ; index $41 => [130, 428, 320, 106, 54] = 1038
    byt $df   ; index $42 => [132, 428, 340, 84, 54] = 1038
    byt $de   ; index $43 => [134, 428, 320, 84, 72] = 1038
    byt $ac   ; index $44 => [136, 428, 226, 142, 106] = 1038
    byt $be   ; index $45 => [138, 380, 320, 128, 72] = 1038
    byt $8f   ; index $46 => [140, 428, 226, 190, 54] = 1038
    byt $bf   ; index $47 => [142, 428, 286, 128, 54] = 1038
    byt $ef   ; index $48 => [144, 428, 340, 72, 54] = 1038
    byt $ee   ; index $49 => [146, 428, 320, 72, 72] = 1038
    byt $ac   ; index $4a => [148, 428, 214, 142, 106] = 1038
    byt $bc   ; index $4b => [150, 428, 226, 128, 106] = 1038
    byt $df   ; index $4c => [152, 428, 320, 84, 54] = 1038
    byt $9c   ; index $4d => [154, 428, 190, 160, 106] = 1038
    byt $dd   ; index $4e => [156, 428, 286, 84, 84] = 1038
    byt $ad   ; index $4f => [158, 428, 226, 142, 84] = 1038
    byt $af   ; index $50 => [160, 428, 254, 142, 54] = 1038
    byt $ff   ; index $51 => [162, 428, 340, 54, 54] = 1038
    byt $ef   ; index $52 => [164, 428, 320, 72, 54] = 1038
    byt $cd   ; index $53 => [166, 428, 254, 106, 84] = 1038
    byt $de   ; index $54 => [168, 428, 286, 84, 72] = 1038
    byt $9f   ; index $55 => [170, 428, 226, 160, 54] = 1038
    byt $bd   ; index $56 => [172, 428, 226, 128, 84] = 1038
    byt $bf   ; index $57 => [174, 428, 254, 128, 54] = 1038
    byt $8f   ; index $58 => [176, 428, 190, 190, 54] = 1038
    byt $ce   ; index $59 => [178, 428, 254, 106, 72] = 1038
    byt $ee   ; index $5a => [180, 428, 286, 72, 72] = 1038
    byt $ff   ; index $5b => [182, 428, 320, 54, 54] = 1038
    byt $be   ; index $5c => [184, 428, 226, 128, 72] = 1038
    byt $df   ; index $5d => [186, 428, 286, 84, 54] = 1038
    byt $dd   ; index $5e => [188, 428, 254, 84, 84] = 1038
    byt $bf   ; index $5f => [190, 380, 286, 128, 54] = 1038
    byt $ef   ; index $60 => [192, 380, 340, 72, 54] = 1038
    byt $cd   ; index $61 => [194, 428, 226, 106, 84] = 1038
    byt $cf   ; index $62 => [196, 428, 254, 106, 54] = 1038
    byt $ef   ; index $63 => [198, 428, 286, 72, 54] = 1038
    byt $de   ; index $64 => [200, 428, 254, 84, 72] = 1038
    byt $bf   ; index $65 => [202, 428, 226, 128, 54] = 1038
    byt $dd   ; index $66 => [204, 380, 286, 84, 84] = 1038
    byt $ce   ; index $67 => [206, 428, 226, 106, 72] = 1038
    byt $bd   ; index $68 => [208, 428, 190, 128, 84] = 1038
    byt $ff   ; index $69 => [210, 380, 340, 54, 54] = 1038
    byt $ee   ; index $6a => [212, 428, 254, 72, 72] = 1038
    byt $bf   ; index $6b => [214, 428, 214, 128, 54] = 1038
    byt $ff   ; index $6c => [216, 428, 286, 54, 54] = 1038
    byt $df   ; index $6d => [218, 428, 254, 84, 54] = 1038
    byt $be   ; index $6e => [220, 428, 190, 128, 72] = 1038
    byt $bf   ; index $6f => [222, 380, 254, 128, 54] = 1038
    byt $cf   ; index $70 => [224, 428, 226, 106, 54] = 1038
    byt $bb   ; index $71 => [226, 428, 128, 128, 128] = 1038
    byt $de   ; index $72 => [228, 428, 226, 84, 72] = 1038
    byt $ef   ; index $73 => [230, 428, 254, 72, 54] = 1038
    byt $be   ; index $74 => [232, 380, 226, 128, 72] = 1038
    byt $bc   ; index $75 => [234, 428, 142, 128, 106] = 1038
    byt $cf   ; index $76 => [236, 428, 214, 106, 54] = 1038
    byt $bf   ; index $77 => [238, 428, 190, 128, 54] = 1038
    byt $ee   ; index $78 => [240, 428, 226, 72, 72] = 1038
    byt $ce   ; index $79 => [242, 428, 190, 106, 72] = 1038
    byt $cf   ; index $7a => [244, 380, 254, 106, 54] = 1038
    byt $df   ; index $7b => [246, 428, 226, 84, 54] = 1038
    byt $ff   ; index $7c => [248, 428, 254, 54, 54] = 1038
    byt $be   ; index $7d => [250, 428, 160, 128, 72] = 1038
    byt $ee   ; index $7e => [252, 428, 214, 72, 72] = 1038
    byt $af   ; index $7f => [254, 428, 160, 142, 54] = 1038
    byt $bd   ; index $80 => [256, 428, 142, 128, 84] = 1038
    byt $ef   ; index $81 => [258, 428, 226, 72, 54] = 1038
    byt $cf   ; index $82 => [260, 428, 190, 106, 54] = 1038
    byt $bf   ; index $83 => [262, 380, 214, 128, 54] = 1038
    byt $de   ; index $84 => [264, 428, 190, 84, 72] = 1038
    byt $df   ; index $85 => [266, 380, 254, 84, 54] = 1038
    byt $bf   ; index $86 => [268, 428, 160, 128, 54] = 1038
    byt $ef   ; index $87 => [270, 428, 214, 72, 54] = 1038
    byt $ce   ; index $88 => [272, 428, 160, 106, 72] = 1038
    byt $bb   ; index $89 => [274, 380, 128, 128, 128] = 1038
    byt $ff   ; index $8a => [276, 428, 226, 54, 54] = 1038
    byt $cd   ; index $8b => [278, 428, 142, 106, 84] = 1038
    byt $bd   ; index $8c => [280, 320, 226, 128, 84] = 1038
    byt $df   ; index $8d => [282, 428, 190, 84, 54] = 1038
    byt $cf   ; index $8e => [284, 380, 214, 106, 54] = 1038
    byt $bf   ; index $8f => [286, 428, 142, 128, 54] = 1038
    byt $ff   ; index $90 => [288, 428, 214, 54, 54] = 1038
    byt $cf   ; index $91 => [290, 428, 160, 106, 54] = 1038
    byt $cd   ; index $92 => [292, 428, 128, 106, 84] = 1038
    byt $ef   ; index $93 => [294, 428, 190, 72, 54] = 1038
    byt $ff   ; index $94 => [296, 380, 254, 54, 54] = 1038
    byt $be   ; index $95 => [298, 380, 160, 128, 72] = 1038
    byt $dd   ; index $96 => [300, 428, 142, 84, 84] = 1038
    byt $af   ; index $97 => [302, 380, 160, 142, 54] = 1038
    byt $ce   ; index $98 => [304, 428, 128, 106, 72] = 1038
    byt $ee   ; index $99 => [306, 428, 160, 72, 72] = 1038
    byt $cf   ; index $9a => [308, 428, 142, 106, 54] = 1038
    byt $bf   ; index $9b => [310, 320, 226, 128, 54] = 1038
    byt $ff   ; index $9c => [312, 428, 190, 54, 54] = 1038
    byt $dd   ; index $9d => [314, 428, 128, 84, 84] = 1038
    byt $bf   ; index $9e => [316, 380, 160, 128, 54] = 1038
    byt $ef   ; index $9f => [318, 380, 214, 72, 54] = 1038
    byt $ce   ; index $a0 => [320, 380, 160, 106, 72] = 1038
    byt $cf   ; index $a1 => [322, 428, 128, 106, 54] = 1038
    byt $ef   ; index $a2 => [324, 428, 160, 72, 54] = 1038
    byt $de   ; index $a3 => [326, 428, 128, 84, 72] = 1038
    byt $ee   ; index $a4 => [328, 340, 226, 72, 72] = 1038
    byt $df   ; index $a5 => [330, 428, 142, 84, 54] = 1038
    byt $cf   ; index $a6 => [332, 320, 226, 106, 54] = 1038
    byt $bf   ; index $a7 => [334, 380, 142, 128, 54] = 1038
    byt $dd   ; index $a8 => [336, 428, 106, 84, 84] = 1038
    byt $ee   ; index $a9 => [338, 428, 128, 72, 72] = 1038
    byt $cd   ; index $aa => [340, 380, 128, 106, 84] = 1038
    byt $ff   ; index $ab => [342, 428, 160, 54, 54] = 1038
    byt $df   ; index $ac => [344, 428, 128, 84, 54] = 1038
    byt $ef   ; index $ad => [346, 340, 226, 72, 54] = 1038
    byt $de   ; index $ae => [348, 428, 106, 84, 72] = 1038
    byt $ce   ; index $af => [350, 320, 190, 106, 72] = 1038
    byt $ce   ; index $b0 => [352, 380, 128, 106, 72] = 1038
    byt $ee   ; index $b1 => [354, 380, 160, 72, 72] = 1038
    byt $ef   ; index $b2 => [356, 428, 128, 72, 54] = 1038
    byt $dd   ; index $b3 => [358, 428, 84, 84, 84] = 1038
    byt $ff   ; index $b4 => [360, 428, 142, 54, 54] = 1038
    byt $dd   ; index $b5 => [362, 380, 128, 84, 84] = 1038
    byt $ff   ; index $b6 => [364, 340, 226, 54, 54] = 1038
    byt $df   ; index $b7 => [366, 428, 106, 84, 54] = 1038
    byt $cf   ; index $b8 => [368, 320, 190, 106, 54] = 1038
    byt $de   ; index $b9 => [370, 428, 84, 84, 72] = 1038
    byt $ef   ; index $ba => [372, 380, 160, 72, 54] = 1038
    byt $ff   ; index $bb => [374, 428, 128, 54, 54] = 1038
    byt $ff   ; index $bc => [376, 340, 214, 54, 54] = 1038
    byt $ef   ; index $bd => [378, 428, 106, 72, 54] = 1038
    byt $cd   ; index $be => [380, 340, 128, 106, 84] = 1038
    byt $ee   ; index $bf => [382, 428, 84, 72, 72] = 1038
    byt $dd   ; index $c0 => [384, 380, 106, 84, 84] = 1038
    byt $ee   ; index $c1 => [386, 380, 128, 72, 72] = 1038
    byt $df   ; index $c2 => [388, 428, 84, 84, 54] = 1038
    byt $ff   ; index $c3 => [390, 380, 160, 54, 54] = 1038
    byt $df   ; index $c4 => [392, 380, 128, 84, 54] = 1038
    byt $ee   ; index $c5 => [394, 428, 72, 72, 72] = 1038
    byt $ff   ; index $c6 => [396, 428, 106, 54, 54] = 1038
    byt $cf   ; index $c7 => [398, 320, 160, 106, 54] = 1038
    byt $ef   ; index $c8 => [400, 428, 84, 72, 54] = 1038
    byt $dd   ; index $c9 => [402, 340, 128, 84, 84] = 1038
    byt $ef   ; index $ca => [404, 380, 128, 72, 54] = 1038
    byt $dd   ; index $cb => [406, 380, 84, 84, 84] = 1038
    byt $ff   ; index $cc => [408, 380, 142, 54, 54] = 1038
    byt $cf   ; index $cd => [410, 340, 128, 106, 54] = 1038
    byt $ef   ; index $ce => [412, 428, 72, 72, 54] = 1038
    byt $df   ; index $cf => [414, 380, 106, 84, 54] = 1038
    byt $cf   ; index $d0 => [416, 320, 142, 106, 54] = 1038
    byt $ff   ; index $d1 => [418, 428, 84, 54, 54] = 1038
    byt $ff   ; index $d2 => [420, 320, 190, 54, 54] = 1038
    byt $ff   ; index $d3 => [422, 380, 128, 54, 54] = 1038
    byt $dd   ; index $d4 => [424, 340, 106, 84, 84] = 1038
    byt $ef   ; index $d5 => [426, 380, 106, 72, 54] = 1038
    byt $bf   ; index $d6 => [428, 286, 142, 128, 54] = 1038
    byt $ff   ; index $d7 => [430, 428, 72, 54, 54] = 1038