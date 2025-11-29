; GC_COLOR_JUGADOR_ACTUAL
;  - Pone el atributo/color del jugador actual en un bloque 3x3
;  - Convenios:
;      D contiene el color base del jugador (ej. 2 o 6)
;      BLINK es el bit de parpadeo; se añade para el efecto visual
;      INC_HL_3X3 escribe/avanza sobre un bloque 3x3 usando (HL)
;  - Efecto: carga A con D|BLINK y aplica ese atributo en la celda base $5845 (3 llamadas -> 3 filas del bloque)
GC_COLOR_JUGADOR_ACTUAL:
    LD A, (JUGADOR_ACTUAL)
    LD HL, $00
    CP 2: CALL Z, SET_HL_J2
    LD A, (COLOR_JUGADOR_ACTUAL)
    ADD BLINK
    CALL GC_COLOR_CIRCLE
    RET

SET_HL_J2
    LD HL, $06
    RET

; RECIBE UNA DIRECCION HL DONDE H = FILA DEL TABLERO, L = COLUMNA DEL TABLERO Y COLOREA TODO EL CIRCULO, 
; OJO, EN A RECIBE UNICAMENTE EL COLOR DEL INK A PINTAR, EL PAPER Y EL BRIGHT LO DEBE RESPETAR
GC_COLOR_CIRCLE:
    PUSH HL: PUSH AF: PUSH BC: PUSH DE
    CALL LC_SLOT_POINTER ; HL = DIRECCION DE VIDEORAM DEL PAR FILA COLUMNA
    LD BC, $1E
    LD D, A
    LD A, %01111000: AND (HL): ADD A, D
    LD (HL), A: INC HL: LD (HL), A: INC HL: LD (HL), A: ADD HL, BC
    LD (HL), A: INC HL: LD (HL), A: INC HL: LD (HL), A: ADD HL, BC
    LD (HL), A: INC HL: LD (HL), A: INC HL: LD (HL), A: ADD HL, BC ; EL CIRCULO HA SIDO COLOREADO POR COMPLETO
    POP DE: POP BC: POP AF: POP HL

    RET

; GC_LEFT
;  - Borra (pone NEGRO) un bloque 3x3 en la posición actual apuntada por HL,
;    desplaza HL hacia la izquierda (restando 3) y vuelve a borrar el bloque
;  - Notas:
;    ADD HL, $FFFD es equivalente a HL -= 3 (0xFFFD = -3 en aritmética de 16 bits)
;    Se usan múltiples PUSH/POP para preservar registros y valores temporales
GC_LEFT:
    PUSH AF
    LD A, NEGRO
    CALL GC_COLOR_CIRCLE
    DEC L; HL VALE FILA,COLUMNA+1
    LD A, (COLOR_JUGADOR_ACTUAL)
    ADD BLINK
    CALL GC_COLOR_CIRCLE ; HL VALE FILA, COLUMNA + 1 AL FINALIZAR (RESPECTO A VALOR ORIGINAL)
    POP AF

    RET

; GC_RIGHT
;  - Simétrico a GC_LEFT: borra el bloque 3x3 actual, desplaza HL a la derecha (+3)
;    y borra el nuevo bloque. Usado para desplazar un cursor/selección a la derecha.
;  - ADD HL, 3 mueve la posición 3 bytes adelante (una columna/columna visual de 3)
GC_RIGHT:
    PUSH AF
    LD A, NEGRO
    CALL GC_COLOR_CIRCLE
    INC L; HL VALE FILA,COLUMNA+1
    LD A, (COLOR_JUGADOR_ACTUAL)
    ADD BLINK
    CALL GC_COLOR_CIRCLE ; HL VALE FILA, COLUMNA + 1 AL FINALIZAR (RESPECTO A VALOR ORIGINAL)
    POP AF

    RET

GC_ENTER:
    PUSH AF
    PUSH BC
    PUSH DE
    
SOLTAR_FICHA_BUCLE:
    ; ERASE current circle
    LD A, NEGRO
    CALL GC_COLOR_CIRCLE
    
    INC H
    LD A, (COLOR_JUGADOR_ACTUAL)
    CALL GC_COLOR_CIRCLE

    CALL U_ESPERAR

    ; Calculate TABLERO_ACTUAL position for new H,L
    CALL U_CALC_TABLERO_POS      ; Returns IX pointing to TABLERO_ACTUAL[H][L]
    ; Check if position is free
    LD A, (IX)
    OR A
    JR NZ, FICHA_LANDED
    JR SOLTAR_FICHA_BUCLE

FICHA_LANDED:
    ; Paint final circle position  
    ; DEC H                      ; Go back to last valid position
    ; LD A, (COLOR_JUGADOR_ACTUAL)
    ; CALL GC_COLOR_CIRCLE
    
    ; Calculate correct TABLERO_ACTUAL position and save piece
    DEC H
    CALL U_CALC_TABLERO_POS      ; IX now points to correct position
    LD A, (JUGADOR_ACTUAL)
    LD (IX), A
    
    POP DE: POP BC :POP AF
    RET