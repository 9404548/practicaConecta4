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
; El jugador 2 empieza en la columna 6 (Fila = 0, Columna = 6)
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

; GC_ENTER
;   - Rutina que realiza los procesos gráficos tras pulsar para bajar una ficha en una determinada columna 
;   - La rutina simula la caída de la ficha borrando, pintando, esperando y comprobando si puede volver a bajar.
GC_ENTER:
    PUSH AF
    PUSH BC
    PUSH DE

; SOLTAR_FICHA_BUCLE
; - Rutina que simula la caída de una ficha en la columna seleccionada
; - INC H para moverse a la siguiente fila
; - Se hace una pausa para que se vea el movimiento
SOLTAR_FICHA_BUCLE:
    ; Borrar círculo actual
    LD A, NEGRO
    CALL GC_COLOR_CIRCLE
    ; Pintarlo una fila más abajo
    INC H
    LD A, (COLOR_JUGADOR_ACTUAL)
    CALL GC_COLOR_CIRCLE
    ; Esperar
    CALL U_ESPERAR

    ; Comprobar si se puede volver a pintar
    CALL U_CALC_TABLERO_POS      ; Devuelve IX en la posición (H,L) fila, columna actual.
    ; Comprobar si la posición de abajo está libre 
    LD A, (IX)
    OR A
    JR NZ, FICHA_LANDED ; Si no es cero, la posición está ocupada y se tiene que bajar la ficha
    JR SOLTAR_FICHA_BUCLE   ; Si es cero, se sigue bajando la ficha

; FICHA_LANDED
; - DEC H devuelve la coordenada a la ultima posicion vacia valida
; - Con LD (IX), A se guarda la ficha del jugador actual en la "memoria del tablero"
FICHA_LANDED:
    ; Calculate correct TABLERO_ACTUAL position and save piece
    DEC H
    CALL U_CALC_TABLERO_POS      ; IX apunta a la posición actual en memoria
    LD A, (JUGADOR_ACTUAL) ; 1 o 2, según el turno.
    LD (IX), A ; Guarda que ese espacio está ocupado por el jugador que ha tirado
    
    POP DE: POP BC :POP AF
    RET