        align 16
table_irq_frame_0:
        IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE128
        IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE160
        IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE226
        IRQ_CALL irq_set_rate_and_advance, DMCFREQ_IRQ_RATE54

        align 16
table_irq_frame_1:
        IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE128
        IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE286
        IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE54
        IRQ_CALL irq_set_two_rates_and_advance, DMCFREQ_IRQ_RATE428, DMCFREQ_IRQ_RATE54

        align 16
table_irq_frame_2:
        IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE128
        IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE286
        IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE54
        IRQ_CALL irq_set_two_rates_and_advance, DMCFREQ_IRQ_RATE428, DMCFREQ_IRQ_RATE54

        align 16
table_irq_frame_3:
        IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE128
        IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE286
        IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE54
        IRQ_CALL irq_set_two_rates_and_advance, DMCFREQ_IRQ_RATE428, DMCFREQ_IRQ_RATE54

        align 16
table_irq_frame_4:
        IRQ_CALL irq_blank_enter,   DMCFREQ_IRQ_RATE428
        IRQ_CALL irq_set_rate,      DMCFREQ_IRQ_RATE214
        IRQ_CALL irq_set_rate,      DMCFREQ_IRQ_RATE54
        IRQ_CALL irq_blank_exit,    DMCFREQ_IRQ_RATE214,    DMCFREQ_IRQ_RATE72

        align 16
table_irq_frame_5:
        IRQ_CALL irq_blank_enter,   DMCFREQ_IRQ_RATE428
        IRQ_CALL irq_set_rate,      DMCFREQ_IRQ_RATE190
        IRQ_CALL irq_set_rate,      DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_blank_exit,    DMCFREQ_IRQ_RATE160,    DMCFREQ_IRQ_RATE54

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

        ; end of road
        IRQ_CALL irq_set_two_rates, DMCFREQ_IRQ_RATE428, DMCFREQ_IRQ_RATE72

        ; top of map
        rept 17
            IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE54
        endm
        IRQ_CALL irq_set_two_rates, DMCFREQ_IRQ_RATE320, DMCFREQ_IRQ_RATE380

        ; last 8 rows of map
        IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE72

        ; end of map
        IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE428
        IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE226
        ; Terminating row.
        IRQ_CALL irq_reset_to_frame, DMCFREQ_IRQ_RATE226


        align 16
table_frame_offset:
        ; Frame loop 0-3, also
        ; 1: left, 2: right
        byt $FF, $00, $01, $02
        ; 4: down, 5: up
        byt $FF, $01
