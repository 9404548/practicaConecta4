; pantalla_juego.asm - Rutinas para dibujar y preparar la pantalla de juego

; SCR_PTLLA_JUEGO: Inicializa la pantalla del juego
SCR_PTLLA_JUEGO:
    PUSH BC: PUSH HL: PUSH DE: PUSH AF
    LD A, 0                  ; valor inicial
    ; LD HL, $0405
    ; CALL COORD_ATRIB        ; ejemplo de cálculo de dirección 
    LD HL, $58A5              ; dirección base para la cuadrícula de atributos
    CALL SET_GRID_EMPTY       ; pinta la cuadrícula vacía (atributos)
    LD HL, $40A5              ; dirección base para los píxeles
    CALL DRAW_EMPTY_CIRCLES   ; dibuja los círculos vacíos
    POP AF: POP DE: POP HL: POP BC
    RET

; SET_GRID_EMPTY: Pinta las 7 columnas de la cuadrícula de atributos
SET_GRID_EMPTY:
    CALL SET_COLUMN_COLOR     ; columna 1
    CALL SET_COLUMN_COLOR     ; columna 2
    CALL SET_COLUMN_COLOR     ; columna 3
    CALL SET_COLUMN_COLOR     ; columna 4
    CALL SET_COLUMN_COLOR     ; columna 5
    CALL SET_COLUMN_COLOR     ; columna 6
    CALL SET_COLUMN_COLOR     ; columna 7
    RET

; DRAW_EMPTY_CIRCLES: Dibuja 8 columnas de círculos vacíos (píxeles)
DRAW_EMPTY_CIRCLES:
    CALL DRAW_CIRCLE_COLUMN   ; columna 1
    CALL DRAW_CIRCLE_COLUMN   ; columna 2
    CALL DRAW_CIRCLE_COLUMN   ; columna 3
    CALL DRAW_CIRCLE_COLUMN   ; columna 4
    CALL DRAW_CIRCLE_COLUMN   ; columna 5
    CALL DRAW_CIRCLE_COLUMN   ; columna 6
    CALL DRAW_CIRCLE_COLUMN   ; columna 7
    CALL DRAW_CIRCLE_COLUMN   ; columna 8
    RET

; DRAW_CIRCLE_ROW: Dibuja una fila de 7 círculos avanzando HL entre cada uno
DRAW_CIRCLE_ROW:
    PUSH HL
    CALL DRAW_CIRCLE
    POP HL: INC HL: INC HL: INC HL: PUSH HL
    CALL DRAW_CIRCLE
    POP HL: INC HL: INC HL: INC HL: PUSH HL
    CALL DRAW_CIRCLE
    POP HL: INC HL: INC HL: INC HL: PUSH HL
    CALL DRAW_CIRCLE
    POP HL: INC HL: INC HL: INC HL: PUSH HL
    CALL DRAW_CIRCLE
    POP HL: INC HL: INC HL: INC HL: PUSH HL
    CALL DRAW_CIRCLE
    POP HL: INC HL: INC HL: INC HL: PUSH HL
    CALL DRAW_CIRCLE
    POP HL
    RET

; DRAW_CIRCLE_COLUMN: Dibuja una columna de 6 círculos y avanza HL a la siguiente columna
DRAW_CIRCLE_COLUMN:
    CALL DRAW_CIRCLE
    CALL DRAW_CIRCLE
    CALL DRAW_CIRCLE
    CALL DRAW_CIRCLE
    CALL DRAW_CIRCLE
    CALL DRAW_CIRCLE
    LD BC, $EFC3              ; offset para saltar a la siguiente columna
    ADD HL, BC
    RET

; VERIFY_4000: Corrige el valor de H si HL cruza ciertos límites de pantalla
VERIFY_4000:
    LD A, $41
    CP H 
    CALL Z, SET_4800          ; si H = $41, corrige a $48
    LD A, $49
    CP H
    CALL Z, SET_5000          ; si H = $49, corrige a $50
    RET

SET_4800:
    LD H, $48                 ; corrige HL a zona válida de pantalla
    RET

SET_5000:
    LD H, $50                 ; corrige HL a zona válida de pantalla
    RET

; SET_COLUMN_COLOR: Pinta 6 bloques de color en una columna y avanza HL
SET_COLUMN_COLOR:
    CALL SET_C_COLOR_E
    CALL SET_C_COLOR_E
    CALL SET_C_COLOR_E
    CALL SET_C_COLOR_E
    CALL SET_C_COLOR_E
    CALL SET_C_COLOR_E
    LD BC, $FDC3              ; offset para saltar a la siguiente columna
    ADD HL, BC
    RET

; DRAW_CIRCLE: Dibuja un círculo completo (3x3 bloques) en la pantalla
DRAW_CIRCLE:
    PUSH BC 
    LD BC, $001D              ; offset para avanzar entre filas

    CALL UL_CIRCLE            ; esquina superior izquierda
    CALL UM_CIRCLE            ; parte superior media
    CALL UR_CIRCLE            ; esquina superior derecha
    
    ADD HL, BC
    CALL VERIFY_4000

    CALL ML_CIRCLE            ; parte media izquierda
    CALL MM_CIRCLE            ; parte media central
    CALL MR_CIRCLE            ; parte media derecha

    ADD HL, BC
    CALL VERIFY_4000

    CALL LL_CIRCLE            ; esquina inferior izquierda
    CALL LM_CIRCLE            ; parte inferior media
    CALL LR_CIRCLE            ; esquina inferior derecha
    
    ADD HL, BC
    CALL VERIFY_4000
    POP BC 
    
    RET

; Las siguientes rutinas dibujan partes de un círculo (segmentos de píxeles)
; Cada una escribe patrones binarios en la memoria de pantalla para formar el círculo
UL_CIRCLE:
    LD A, %00000000
    LD (HL), A
    CALL INC_AND_LOAD_H
    LD A, %00000011
    CALL INC_AND_LOAD_H
    LD A, %00000111
    CALL INC_AND_LOAD_H
    LD A, %00001111
    CALL INC_AND_LOAD_H
    LD A, %00011111
    CALL INC_AND_LOAD_H
    LD A, %00111111
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL SETBACK_HL
    RET

UM_CIRCLE:
    LD A, %00000000
    DEC H
    CALL INC_AND_LOAD_H
    LD A, %01111110
    CALL INC_AND_LOAD_H
    LD A, %11111111
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL SETBACK_HL
    RET

UR_CIRCLE:
    LD A, %00000000
    LD (HL), A
    CALL INC_AND_LOAD_H
    LD A, %11000000
    CALL INC_AND_LOAD_H
    LD A, %11100000
    CALL INC_AND_LOAD_H
    LD A, %11110000
    CALL INC_AND_LOAD_H
    LD A, %11111000
    CALL INC_AND_LOAD_H
    LD A, %11111100
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL SETBACK_HL
    RET

ML_CIRCLE:
    LD A, %00111111
    DEC H
    CALL INC_AND_LOAD_H
    LD A, %01111111
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    LD A, %00111111
    CALL INC_AND_LOAD_H
    CALL SETBACK_HL
    RET

MM_CIRCLE:
    LD A, %11111111
    DEC H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL SETBACK_HL
    RET

MR_CIRCLE:
    LD A, %11111100
    DEC H
    CALL INC_AND_LOAD_H
    LD A, %11111110
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    LD A, %11111100
    CALL INC_AND_LOAD_H
    CALL SETBACK_HL
    RET

LL_CIRCLE:
    LD A, %00111111
    LD (HL), A
    CALL INC_AND_LOAD_H
    LD A, %00011111
    CALL INC_AND_LOAD_H
    LD A, %00001111
    CALL INC_AND_LOAD_H
    LD A, %00000111
    CALL INC_AND_LOAD_H
    LD A, %00000011
    CALL INC_AND_LOAD_H
    LD A, %00000000
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL SETBACK_HL
    RET

LM_CIRCLE:
    LD A, %11111111
    DEC H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    LD A, %01111110
    CALL INC_AND_LOAD_H
    LD A, %00000000
    CALL INC_AND_LOAD_H
    CALL SETBACK_HL
    RET

LR_CIRCLE:
    LD A, %11111100
    LD (HL), A
    CALL INC_AND_LOAD_H
    LD A, %11111000
    CALL INC_AND_LOAD_H
    LD A, %11110000
    CALL INC_AND_LOAD_H
    LD A, %11100000
    CALL INC_AND_LOAD_H
    LD A, %11000000
    CALL INC_AND_LOAD_H
    LD A, %00000000
    CALL INC_AND_LOAD_H
    CALL INC_AND_LOAD_H
    CALL SETBACK_HL
    RET

; INC_AND_LOAD_H: Avanza HL y escribe el valor de A en la nueva posición
INC_AND_LOAD_H:
    LD DE, BC
    LD BC, $0100
    ADD HL, BC
    LD (HL), A
    LD BC, DE
    RET

; SETBACK_HL: Retrocede HL a la posición original tras dibujar una fila
SETBACK_HL:
    LD DE, BC
    LD BC, $F901
    ADD HL, BC
    LD BC, DE
    RET

; INC_HL_3X3: Escribe el valor de A en tres posiciones consecutivas y avanza HL
INC_HL_3X3:
    PUSH AF: PUSH BC: PUSH DE
    LD (HL), A
    LD DE, BC
    INC HL
    LD (HL), A
    INC HL
    LD (HL), A
    LD BC, 30
    ADD HL, BC
    POP DE: POP BC: POP AF
    RET

; SET_C_COLOR_E: Pinta un bloque de color en la cuadrícula de atributos
SET_C_COLOR_E:
    LD A, 1*8+7
    CALL INC_HL_3X3
    CALL INC_HL_3X3
    CALL INC_HL_3X3
    RET

; CONVERT_58_2_40: Convierte una dirección $58XX a $40XX (zona de pantalla)
CONVERT_58_2_40 ; CONVIERTE UNA DIRECCION DE MEMORIA QUE COMIENZA CON $58XX A $40XX
    LD BC, $E800
    ADD HL, BC
    RET