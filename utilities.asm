UTILITIES: JR UTILITIES

U_CALC_TABLERO_POS:
    ; Calculate IX = TABLERO_ACTUAL + (L * 7) + H
    ; Where H = row, L = column in original grid coordinates
    
    LD A, L                    ; Get column (L)
    LD B, A                    ; Save L in B
    ADD A, A                   ; A = L * 2
    ADD A, A                   ; A = L * 4  
    ADD A, A                   ; A = L * 8
    SUB B                      ; A = L * 7 (since 8L - L = 7L)
    ADD A, H                   ; A = (L * 7) + H
    
    LD IX, TABLERO_ACTUAL      ; Base address
    LD D, 0
    LD E, A                    ; DE = offset
    ADD IX, DE                 ; IX points to TABLERO_ACTUAL[L][H]
    
    RET

; Rutina de espera (~0,5 seg)
U_ESPERAR:
    PUSH BC
    LD BC, 76923               ; Approximately 2M / 26 T-states per loop
    
ESPERAR_LOOP:
    DEC BC                     ; 6 T-states
    LD A, B                    ; 4 T-states
    OR C                       ; 4 T-states
    NOP                        ; 4 T-states
    NOP                        ; 4 T-states  
    NOP                        ; 4 T-states
    JR NZ, ESPERAR_LOOP        ; 12 T-states (taken)
    
    POP BC
    RET