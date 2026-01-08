UTILITIES: JR UTILITIES
; #######################################################################
; PLANTILLA DOCUMENTACION DE RUTINAS
; #######################################################################
; TITULO_RUTINA
; RECIBE: [VALORES O REGISTROS QUE RECIBE PARA FUNCIONAR CORRECTAMENTE]
; DEVUELVE: [VALORES O REGISTROS QUE DEVUELVE AL TERMINAR EJECUCION]
; USO: [PARA QUE SE UTILIZA]
; NOTAS: [ASPECTOS A CONSIDERAR EN EL USO DE LA RUTINA] 



U_CALC_TABLERO_POS:
    ; Calcula IX = TABLERO_ACTUAL + (L * 7) + H
    ; Donde H = row, L = columna en coordenadas originales de tablero
    
    LD A, L                    ; Guarda columna (L)
    LD B, A                    ; guarda L en B
    ADD A, A                   ; A = L * 2
    ADD A, A                   ; A = L * 4  
    ADD A, A                   ; A = L * 8
    SUB B                      ; A = L * 7 (ya que 8L - L = 7L)
    ADD A, H                   ; A = (L * 7) + H
    
    LD IX, TABLERO_ACTUAL      ; Dirección de (0,0)
    LD D, 0
    LD E, A                    ; DE = desplazamiento
    ADD IX, DE                 ; IX apunta a tablero actual (h,l)
    
    RET

; Rutina de espera
U_ESPERAR:
    PUSH BC
    LD BC, 11387               
    
ESPERAR_LOOP:
    DEC BC                     ; 6C
    LD A, B                    ; 4C
    OR C                       ; 4C
    NOP                        ; 4C
    NOP                        ; 4C  
    NOP                        ; 4C
    JR NZ, ESPERAR_LOOP        ; 12C
    
    POP BC
    RET