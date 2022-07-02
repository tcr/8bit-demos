; python gen_irq_routines_table.py > src/irq_routines_table.asm

        align 256
irq_routines_table:
        WORD irq_routine_vblank_start
            byt DMCFREQ_IRQ_RATE428
        WORD irq_routine_one_step
            byt DMCFREQ_IRQ_RATE428
        WORD irq_routine_one_step
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_one_step
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_two_step
            byt DMCFREQ_IRQ_RATE320, DMCFREQ_IRQ_RATE54

        WORD irq_routine_row_light
            byt DMCFREQ_IRQ_RATE84
        WORD irq_routine_row_dark
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_light
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_dark
            byt DMCFREQ_IRQ_RATE84
        WORD irq_routine_row_light
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_dark
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_light
            byt DMCFREQ_IRQ_RATE84
        WORD irq_routine_row_dark
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_light
            byt DMCFREQ_IRQ_RATE84
        WORD irq_routine_row_dark
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_light
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_dark
            byt DMCFREQ_IRQ_RATE84
        WORD irq_routine_row_light
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_dark
            byt DMCFREQ_IRQ_RATE84
        WORD irq_routine_row_light
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_dark
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_light
            byt DMCFREQ_IRQ_RATE84
        WORD irq_routine_row_dark
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_light
            byt DMCFREQ_IRQ_RATE84
        WORD irq_routine_row_dark
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_light
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_dark
            byt DMCFREQ_IRQ_RATE84
        WORD irq_routine_row_light
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_dark
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_light
            byt DMCFREQ_IRQ_RATE84
        WORD irq_routine_row_dark
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_light
            byt DMCFREQ_IRQ_RATE84
        WORD irq_routine_row_dark
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_light
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_dark
            byt DMCFREQ_IRQ_RATE84
        WORD irq_routine_row_light
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_row_dark
            byt DMCFREQ_IRQ_RATE84

        WORD irq_routine_align_start
            byt DMCFREQ_IRQ_RATE428

irq_routines_table_align_0:
        WORD irq_routine_one_step
            byt DMCFREQ_IRQ_RATE226
        WORD irq_routine_one_step
            byt DMCFREQ_IRQ_RATE54
        WORD irq_routine_one_step
            byt DMCFREQ_IRQ_RATE54
        WORD irq_routine_one_step_align
            byt DMCFREQ_IRQ_RATE54, lo(irq_routines_table_align_3)
        ; cpu cycles = 29782    offset = -1.5

irq_routines_table_align_1:
        WORD irq_routine_one_step
            byt DMCFREQ_IRQ_RATE226
        WORD irq_routine_one_step
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_two_step_align
            byt DMCFREQ_IRQ_RATE340, DMCFREQ_IRQ_RATE54, lo(irq_routines_table_align_0)
        ; cpu cycles = 29780    offset = 0.5

irq_routines_table_align_2:
        WORD irq_routine_one_step
            byt DMCFREQ_IRQ_RATE226
        WORD irq_routine_one_step
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_two_step_align
            byt DMCFREQ_IRQ_RATE340, DMCFREQ_IRQ_RATE54, lo(irq_routines_table_align_1)
        ; cpu cycles = 29780    offset = 0.5

irq_routines_table_align_3:
        WORD irq_routine_one_step
            byt DMCFREQ_IRQ_RATE226
        WORD irq_routine_one_step
            byt DMCFREQ_IRQ_RATE72
        WORD irq_routine_two_step_align
            byt DMCFREQ_IRQ_RATE340, DMCFREQ_IRQ_RATE54, lo(irq_routines_table_align_2)
        ; cpu cycles = 29780    offset = 0.5

