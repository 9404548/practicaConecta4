; GC_COLOR_JUGADOR_ACTUAL
;  - Pone el atributo/color del jugador actual en un bloque 3x3
;  - Convenios:
;      D contiene el color base del jugador (ej. 2 o 6)
;      BLINK es el bit de parpadeo; se añade para el efecto visual
;      INC_HL_3X3 escribe/avanza sobre un bloque 3x3 usando (HL)
;  - Efecto: carga A con D|BLINK y aplica ese atributo en la celda base $5845 (3 llamadas -> 3 filas del bloque)
GC_COLOR_JUGADOR_ACTUAL:
    LD A, (JUGADOR_ACTUAL)
    ADD BLINK
    PUSH AF
    LD HL, $5845
    PUSH HL
    CALL INC_HL_3X3
    CALL INC_HL_3X3
    CALL INC_HL_3X3
    POP HL
    POP AF
    RET

; GC_LEFT
;  - Borra (pone NEGRO) un bloque 3x3 en la posición actual apuntada por HL,
;    desplaza HL hacia la izquierda (restando 3) y vuelve a borrar el bloque
;  - Notas:
;    ADD HL, $FFFD es equivalente a HL -= 3 (0xFFFD = -3 en aritmética de 16 bits)
;    Se usan múltiples PUSH/POP para preservar registros y valores temporales
GC_LEFT:
    PUSH BC: PUSH AF: PUSH DE
    LD A, (HL)        ; guarda el atributo/valor actual en A
    PUSH AF
    LD A, NEGRO       ; A = color NEGRO para «borrar» el bloque 3x3
    PUSH HL
    CALL INC_HL_3X3
    CALL INC_HL_3X3
    CALL INC_HL_3X3
    POP HL
    LD BC, $FFFD      ; valor -3 para mover HL a la izquierda (3 posiciones)
    ADD HL, BC
    POP AF
    PUSH HL
    CALL INC_HL_3X3
    CALL INC_HL_3X3
    CALL INC_HL_3X3
    POP HL
    POP DE: POP AF: POP BC

    RET

; GC_RIGHT
;  - Simétrico a GC_LEFT: borra el bloque 3x3 actual, desplaza HL a la derecha (+3)
;    y borra el nuevo bloque. Usado para desplazar un cursor/selección a la derecha.
;  - ADD HL, 3 mueve la posición 3 bytes adelante (una columna/columna visual de 3)
GC_RIGHT:
    PUSH DE: PUSH BC: PUSH AF
    LD A, (HL)
    PUSH AF
    LD A, NEGRO
    PUSH HL
    CALL INC_HL_3X3
    CALL INC_HL_3X3
    CALL INC_HL_3X3
    POP HL
    LD BC, $3
    ADD HL, BC
    POP AF
    PUSH HL
    CALL INC_HL_3X3
    CALL INC_HL_3X3
    CALL INC_HL_3X3
    POP HL
    POP AF: POP BC: POP DE

    RET
GC_ENTER:
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
GC_DRAW_CIRCLES_TOP:
    ; GC_DRAW_CIRCLES_TOP
    ; Dibuja (o reserva) la fila superior de 7 posiciones en forma de bloques 3x3
    ; Flujo:
    ;  - Se carga HL con la posición base ($5845).
    ;  - Se repite 7 veces un bloque que llama 3 veces a INC_HL_3X3
    ;    (cada llamada afecta una fila del bloque 3x3 o avanza la referencia interna).
    ;  - Después de pintar la fila de bloques se convierte la coordenada y se
    ;    llama a DRAW_CIRCLE_ROW para el dibujo final/representación gráfica.
    ; Notas:
    ;  - Se preservan registros con PUSH/POP para no alterar el contexto del llamador.
    ;  - B se usa como contador (DJNZ), A queda disponible para atributos si es necesario.
    PUSH HL: PUSH AF: PUSH BC: PUSH DE
    LD HL, $5845         ; posición inicial (celda superior izquierda de la fila de círculos)
    PUSH HL              ; guardamos HL temporalmente en la pila
    LD A, 0              ; A puede usarse como atributo (aquí 0 = vacío/blanco)
    LD B, 7              ; número de «círculos»/bloques a dibujar
DRAW_BLANK_CIRCLE:
    ; En cada iteración llamamos INC_HL_3X3 tres veces.
    ; Se espera que INC_HL_3X3 escriba/avance sobre una de las filas del bloque 3x3
    ; (por eso se invoca 3 veces para completar el bloque verticalmente).
    PUSH BC: PUSH HL
    CALL INC_HL_3X3
    CALL INC_HL_3X3
    CALL INC_HL_3X3
    POP HL: POP BC
    DJNZ DRAW_BLANK_CIRCLE
    POP HL               ; recupera la HL original que guardamos antes del bucle

    ; Tras dibujar la fila base, convertimos coordenadas y llamamos al renderer
    CALL CONVERT_58_2_40 ; convierte la referencia 0x58.. a coordenadas utilizable por DRAW_CIRCLE_ROW
    CALL DRAW_CIRCLE_ROW ; dibuja/representa la fila de círculos en la pantalla

    POP DE: POP BC: POP AF: POP HL

    RET
