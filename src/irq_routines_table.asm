; python gen_irq_routines_table.py > src/irq_routines_table.asm

        align 256
irq_routines_table:
        IRQ_CALL irq_routine_vblank_start, DMCFREQ_IRQ_RATE428
        IRQ_CALL irq_routine_one_step, DMCFREQ_IRQ_RATE428
        IRQ_CALL irq_routine_one_step, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_one_step, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_two_step, DMCFREQ_IRQ_RATE320, DMCFREQ_IRQ_RATE54

        IRQ_CALL irq_routine_row_light, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_routine_row_dark, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_light, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_dark, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_routine_row_light, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_dark, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_light, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_routine_row_dark, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_light, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_routine_row_dark, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_light, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_dark, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_routine_row_light, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_dark, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_routine_row_light, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_dark, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_light, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_routine_row_dark, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_light, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_routine_row_dark, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_light, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_dark, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_routine_row_light, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_dark, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_light, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_routine_row_dark, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_light, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_routine_row_dark, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_light, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_dark, DMCFREQ_IRQ_RATE84
        IRQ_CALL irq_routine_row_light, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_row_dark, DMCFREQ_IRQ_RATE84

        IRQ_CALL irq_routine_align_start, DMCFREQ_IRQ_RATE428

irq_routines_table_align_0:
        IRQ_CALL irq_routine_one_step, DMCFREQ_IRQ_RATE226
        IRQ_CALL irq_routine_one_step, DMCFREQ_IRQ_RATE54
        IRQ_CALL irq_routine_one_step, DMCFREQ_IRQ_RATE54
        IRQ_CALL irq_routine_one_step_align, DMCFREQ_IRQ_RATE54, lo(irq_routines_table_align_3)
        ; cpu cycles = 29782    offset = -1.5

irq_routines_table_align_1:
        IRQ_CALL irq_routine_one_step, DMCFREQ_IRQ_RATE226
        IRQ_CALL irq_routine_one_step, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_two_step_align, DMCFREQ_IRQ_RATE340, DMCFREQ_IRQ_RATE54, lo(irq_routines_table_align_0)
        ; cpu cycles = 29780    offset = 0.5

irq_routines_table_align_2:
        IRQ_CALL irq_routine_one_step, DMCFREQ_IRQ_RATE226
        IRQ_CALL irq_routine_one_step, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_two_step_align, DMCFREQ_IRQ_RATE340, DMCFREQ_IRQ_RATE54, lo(irq_routines_table_align_1)
        ; cpu cycles = 29780    offset = 0.5

irq_routines_table_align_3:
        IRQ_CALL irq_routine_one_step, DMCFREQ_IRQ_RATE226
        IRQ_CALL irq_routine_one_step, DMCFREQ_IRQ_RATE72
        IRQ_CALL irq_routine_two_step_align, DMCFREQ_IRQ_RATE340, DMCFREQ_IRQ_RATE54, lo(irq_routines_table_align_2)
        ; cpu cycles = 29780    offset = 0.5

