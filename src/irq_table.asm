        align 16
table_irq_blank_0:
        IRQ_CALL routine_frame_blank_start,   DMCFREQ_IRQ_RATE428
        IRQ_CALL routine_frame_blank_split_1, DMCFREQ_IRQ_RATE214
        IRQ_CALL routine_frame_blank_split_2, DMCFREQ_IRQ_RATE54
        IRQ_CALL routine_frame_end, DMCFREQ_IRQ_RATE190, DMCFREQ_IRQ_RATE54

        align 16
table_irq_blank_1:
        IRQ_CALL routine_frame_blank_start,   DMCFREQ_IRQ_RATE380
        IRQ_CALL routine_frame_blank_split_1, DMCFREQ_IRQ_RATE226
        IRQ_CALL routine_frame_blank_split_2, DMCFREQ_IRQ_RATE106
        IRQ_CALL routine_frame_end, DMCFREQ_IRQ_RATE72, DMCFREQ_IRQ_RATE54

        align 16
table_irq_blank_2:
        IRQ_CALL routine_frame_blank_start,   DMCFREQ_IRQ_RATE428
        IRQ_CALL routine_frame_blank_split_1, DMCFREQ_IRQ_RATE214
        IRQ_CALL routine_frame_blank_split_2, DMCFREQ_IRQ_RATE54
        IRQ_CALL routine_frame_end, DMCFREQ_IRQ_RATE190, DMCFREQ_IRQ_RATE54

        align 16
table_irq_blank_3:
        IRQ_CALL routine_frame_blank_start,   DMCFREQ_IRQ_RATE428
        IRQ_CALL routine_frame_blank_split_1, DMCFREQ_IRQ_RATE214
        IRQ_CALL routine_frame_blank_split_2, DMCFREQ_IRQ_RATE72
        IRQ_CALL routine_frame_end, DMCFREQ_IRQ_RATE54, DMCFREQ_IRQ_RATE54

        align 16
table_irq_blank_4:
        IRQ_CALL routine_frame_blank_start,   DMCFREQ_IRQ_RATE428
        IRQ_CALL routine_frame_blank_split_1, DMCFREQ_IRQ_RATE214
        IRQ_CALL routine_frame_blank_split_2, DMCFREQ_IRQ_RATE54
        IRQ_CALL routine_frame_end, DMCFREQ_IRQ_RATE214, DMCFREQ_IRQ_RATE72

        align 16
table_irq_blank_5:
        IRQ_CALL routine_frame_blank_start,   DMCFREQ_IRQ_RATE428
        IRQ_CALL routine_frame_blank_split_1, DMCFREQ_IRQ_RATE190
        IRQ_CALL routine_frame_blank_split_2, DMCFREQ_IRQ_RATE72
        IRQ_CALL routine_frame_end, DMCFREQ_IRQ_RATE160, DMCFREQ_IRQ_RATE54

        align 16
table_irq_rows:
        IRQ_CALL irq_light_row - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_light_row - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_dark_row  - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_light_row - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_light_row - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72

        IRQ_CALL irq_light_row - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_light_row - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_dark_row  - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_light_row - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_light_row - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72

        IRQ_CALL irq_light_row - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_light_row - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_dark_row  - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_light_row - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_light_row - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72

        IRQ_CALL irq_light_row - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_light_row - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_dark_row  - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_light_row - 0, DMCFREQ_IRQ_RATE72
        ; IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_light_row - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72

        IRQ_CALL irq_light_row - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_light_row - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_dark_row  - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_light_row - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_light_row - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72

        IRQ_CALL irq_light_row - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_light_row - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_dark_row  - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_light_row - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_light_row - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72

        IRQ_CALL irq_light_row - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_dark_row  - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_light_row - 0, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_dark_row  - 4, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_last_row  - 0, DMCFREQ_IRQ_RATE72


        align 256

; * 8
table_frequencies_0:
        byt DMCFREQ_IRQ_RATE428
        byt DMCFREQ_IRQ_RATE380
        byt DMCFREQ_IRQ_RATE428
        byt DMCFREQ_IRQ_RATE428

        byt DMCFREQ_IRQ_RATE428
        byt DMCFREQ_IRQ_RATE428

; * 8
table_frequencies_1:
        byt DMCFREQ_IRQ_RATE214
        byt DMCFREQ_IRQ_RATE226
        byt DMCFREQ_IRQ_RATE214
        byt DMCFREQ_IRQ_RATE214

        byt DMCFREQ_IRQ_RATE214
        byt DMCFREQ_IRQ_RATE190

; * 8
table_frequencies_2:
        byt DMCFREQ_IRQ_RATE54
        byt DMCFREQ_IRQ_RATE106
        byt DMCFREQ_IRQ_RATE54
        byt DMCFREQ_IRQ_RATE72

        byt DMCFREQ_IRQ_RATE54
        byt DMCFREQ_IRQ_RATE72

; * 1
table_frequencies_3:
        byt DMCFREQ_IRQ_RATE190
        byt DMCFREQ_IRQ_RATE72
        byt DMCFREQ_IRQ_RATE190
        byt DMCFREQ_IRQ_RATE54

        byt DMCFREQ_IRQ_RATE214
        byt DMCFREQ_IRQ_RATE160

; * 8
table_frequencies_4:
        byt DMCFREQ_IRQ_RATE54
        byt DMCFREQ_IRQ_RATE54
        byt DMCFREQ_IRQ_RATE54
        byt DMCFREQ_IRQ_RATE54

        byt DMCFREQ_IRQ_RATE72
        byt DMCFREQ_IRQ_RATE54

table_frame_offset:
        ; Frame loop 0-3, also
        ; 1: left, 2: right
        byt $FF, $00, $01, $02
        ; 4: down, 5: up
        byt $FF, $01
