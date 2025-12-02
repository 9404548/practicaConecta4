; logic_flow.asm - Rutinas de control de flujo principal del juego



; LF_INICIALIZACION
;  - Inicializa el estado lógico y gráfico del juego (por ejemplo, dibuja la fila superior de círculos)
;  - D = PLAYER2 (jugador inicial por defecto)
;  - Llama a GC_DRAW_CIRCLES_TOP para preparar la pantalla
LF_INICIALIZACION:
    PUSH AF
    LD A, (JUGADOR_ACTUAL)
    LD D, A
    POP AF
    CALL LF_BOARD_RESET
    RET

; LF_SWITCH_JUGADOR
;  - Cambia el jugador actual (D) entre PLAYER1 y PLAYER2
;  - Si D = PLAYER2, lo cambia a PLAYER1; si D = PLAYER1, lo cambia a PLAYER2
;  - Usa saltos condicionales para seleccionar el nuevo valor
LF_SWITCH_JUGADOR:
    LD A, (JUGADOR_ACTUAL)
    CP JUGADOR2
    JR Z, SET_P1         ; si era PLAYER2, pasa a PLAYER1
    CP JUGADOR1
    JR Z, SET_P2         ; si era PLAYER1, pasa a PLAYER2
SET_P1:
    PUSH AF
    LD A, JUGADOR1
    LD (JUGADOR_ACTUAL), A
    LD A, COLOR_JUGADOR1
    LD (COLOR_JUGADOR_ACTUAL), A
    POP AF
    JR SALIDA
SET_P2:
    PUSH AF
    LD A, JUGADOR2
    LD (JUGADOR_ACTUAL), A
    LD A, COLOR_JUGADOR2
    LD (COLOR_JUGADOR_ACTUAL), A
    POP AF
SALIDA:
    RET

; RESETEA LA CONDICION DEL TABLERO ACTUAL A TODO CEROS EN LA VARIABLE.
LF_BOARD_RESET:
    XOR A                   ; A = 0
    LD (LEFT_COUNTER), A    ; Reseteamos contador izquierdo
    LD (RIGHT_COUNTER), A   ; Reseteamos contador derecho
    LD (GANADOR), A         ; Borramos el ganador anterior
    
    LD B, 7
    LD IX, TABLERO_ACTUAL
    XOR A
BR_BUCLE_EXTERNO:
    PUSH BC
    LD B, 6
BR_BUCLE_INTERNO:
    LD (IX), A
    INC IX
    DJNZ BR_BUCLE_INTERNO
    POP BC
    INC IX
    DJNZ BR_BUCLE_EXTERNO
    RET

; JUGADA_DESPLAZAMIENTO - Administra desplazamiento tras Q/W
LF_JUGADA_DESPLAZAMIENTO:
    CP 'W': CALL Z, GC_RIGHT              ; Desplaza ficha a la derecha
    CP 'O': CALL Z, GC_RIGHT              ; Desplaza ficha a la derecha
    CP 'Q': CALL Z, GC_LEFT               ; Desplaza ficha a la izquierda
    CP 'I': CALL Z, GC_LEFT               ; Desplaza ficha a la izquierda
    LD A, $FF
    RET