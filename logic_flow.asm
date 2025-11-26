; logic_flow.asm - Rutinas de control de flujo principal del juego

; LF_ESPERAR
;  - Rutina de espera/bloqueo para temporización (delay)
;  - Usa un bucle con BC como contador para generar una pausa de ~0,49 segundos
;  - No modifica registros fuera de BC/AF
LF_ESPERAR:
    PUSH BC
    PUSH AF
    LD BC, CONTADOR      ; carga el valor de espera en BC
LF_ESPERAR1: 
    DEC BC               ; decrementa el contador
    LD A, B
    OR C                 ; si BC != 0, sigue esperando
    NOP                  ; instrucción de relleno para ajustar la duración
    JR NZ, LF_ESPERAR1   ; repite hasta que BC = 0
    ; DURACION TOTAL = APROX 0,49 SEG (según valor de CONTADOR y velocidad CPU)
    POP AF
    POP BC
    RET

; LF_INICIALIZACION
;  - Inicializa el estado lógico y gráfico del juego (por ejemplo, dibuja la fila superior de círculos)
;  - D = PLAYER2 (jugador inicial por defecto)
;  - Llama a GC_DRAW_CIRCLES_TOP para preparar la pantalla
LF_INICIALIZACION:
    LD D, PLAYER2
    CALL LF_BOARD_RESET
    CALL GC_DRAW_CIRCLES_TOP
    RET

; LF_SWITCH_JUGADOR
;  - Cambia el jugador actual (D) entre PLAYER1 y PLAYER2
;  - Si D = PLAYER2, lo cambia a PLAYER1; si D = PLAYER1, lo cambia a PLAYER2
;  - Usa saltos condicionales para seleccionar el nuevo valor
LF_SWITCH_JUGADOR:
    LD A, D
    CP PLAYER2
    JR Z, SET_P1         ; si era PLAYER2, pasa a PLAYER1
    CP PLAYER1
    JR Z, SET_P2         ; si era PLAYER1, pasa a PLAYER2
    ; RET                ; si no coincide, no hace nada
SET_P1:
    LD D, PLAYER1
    JR SALIDA
SET_P2:
    LD D, PLAYER2
SALIDA:
    RET

; RESETEA LA CONDICION DEL TABLERO ACTUAL A TODO CEROS.
LF_BOARD_RESET:
    LD B, 42
    LD IX, TABLERO_ACTUAL
    XOR A
BR_BUCLE:
    LD (IX), A
    DJNZ BR_BUCLE
    RET
