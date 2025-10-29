GC_COLOR_JUGADOR_ACTUAL:
; SET_C_COLOR_R:
;     LD A, 1*8+2
;     CALL INC_HL_3X3
;     CALL INC_HL_3X3
;     CALL INC_HL_3X3
;     RET

; SET_C_COLOR_Y: ; LA RUTINA CAMBIA EL COLOR DE UN DETERMINADO BLOQUE 3X3 A AMARILLO
;     LD A, 1*8+6
;     CALL INC_HL_3X3
;     CALL INC_HL_3X3
;     CALL INC_HL_3X3
;     RET

; ; SET_PRED ; Rutina para indicar que el jugador actual es el rojo
; ;     LD HL, $5845
; ;     LD A, 2
; ;     CALL INC_HL_3X3
; ;     CALL INC_HL_3X3
; ;     CALL INC_HL_3X3
; ;     LD HL, $5845
; ;     CALL CONVERT_58_2_40
; ;     CALL DRAW_CIRCLE
; ;     RET

; ; SET_PYEL ; Rutina para indicar que el jugador actual es el amarillo
; ;     LD HL, $5857
; ;     LD A, 6
; ;     CALL INC_HL_3X3
; ;     CALL INC_HL_3X3
; ;     CALL INC_HL_3X3
; ;     LD HL, $5857
; ;     CALL CONVERT_58_2_40
; ;     CALL DRAW_CIRCLE
; ;     RET