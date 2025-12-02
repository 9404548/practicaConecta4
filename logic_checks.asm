; Lógica de comprobaciones del juego (Conecta 4)
; Constantes y configuración:
ULTIMA_FICHA_COLUMNA EQU $C001 ; Byte (0-6) con la columna de la última ficha jugada
ULTIMA_FICHA_FILA EQU $C002    ; Byte (0-5) con la fila de la última ficha jugada
TABLERO_ANCHO EQU 7
TABLERO_ALTO EQU 6
ESTADO_TABLERO EQU $D000      ; dirección base en memoria donde se almacena el tablero (fila-major)
; Nota: se espera que otras rutinas escriban la columna/fila en las direcciones ULTIMA_FICHA_* antes de llamar

; Comrpueba el resultado del juego tras una jugada, necesita modificaciones
LC_COMPROBAR_RESULTADO:
    CALL LC_COMPROBAR_VICTORIA_JUGADOR
    CP 0: RET Z ; RET SI ALGUIEN GANÓ, A = 0
    CALL LC_COMPROBAR_TABLERO_LLENO
    CP 0: RET C ; RET SI NADIE GANÓ Y SE LLENÓ EL TABLERO, A = 1
    LD A, 128: OR A
    RET ; RET SI NADIE GANÓ Y NO SE LLENÓ EL TABLERO, A = 128

; Rutina para comprobar si el tablero se ha llenado
LC_COMPROBAR_TABLERO_LLENO:
    LD IX, TABLERO_ACTUAL
    LD B, 7
    LD DE, 6
CTL_BUCLE:
    LD A, (IX)
    OR A
    RET Z ; RET SIN EMPATE, A = 0
    ADD IX, DE
    DJNZ CTL_BUCLE
    LD A, 1
    RET ; RET CON EMPATE, A = 128
   
; Rutina que comprueba si el jugador ha ganado por alguna línea, ya sea vertical, horizontal o diagonal.
LC_COMPROBAR_VICTORIA_JUGADOR:
    ; Comprobamos Horizontal
    CALL LC_COMPROBAR_4_EN_RAYA_HORIZONTAL
    CP 4                         ; Comparamos el resultado con 4
    JR NC, VICTORIA_CONFIRMADA   ; Si A >= 4 (No Carry), saltamos a victoria

    ; Comprobamos Vertical
    CALL LC_COMPROBAR_4_EN_RAYA_VERTICAL
    CP 4
    JR NC, VICTORIA_CONFIRMADA

    ; Comprobamos Diagonales
    CALL LC_COMPROBAR_4_EN_RAYA_DIAGONALES
    CP 4
    JR NC, VICTORIA_CONFIRMADA

    ; SI LLEGAMOS AQUÍ, NADIE GANÓ
    LD A, 1      ; Cargamos 1 (Código de "Sigue jugando")
    OR A         ; Aseguramos que el flag Z se apague 
    RET          ; Volvemos

VICTORIA_CONFIRMADA:
    CALL HAY_GANADOR  ; Guarda el ganador y pone A=0
    RET               ; Devuelve A=0 (Victoria)

; Guarda en la variable ganador el color del jugador actual
HAY_GANADOR:
    LD A, (COLOR_JUGADOR_ACTUAL)
    LD (GANADOR), A
    XOR A
    RET ; RET CON GANADOR, A = 0

; ############################################################################
; ############### COMPROBAR 4 EN RAYA EN DISTINTAS DIRECCIONES ###############
; ############################################################################

; Comprueba si se ha obtenido 4 en raya por línea horizontal
LC_COMPROBAR_4_EN_RAYA_HORIZONTAL:
    PUSH HL
    LD IX, TABLERO_ACTUAL
    CALL U_CALC_TABLERO_POS
    LD DE, $FFF9 ; -7 en complemento a 2 para desplazarse por columnas hacia la izquierda en IX
    LD C, 0   
CONTAR_IZQUIERDA:
    LD A, (JUGADOR_ACTUAL) ; Se guarda el color del jugador actual
    LD B, A ; Se guarda en B
    ADD IX, DE ; Desplazamos IX una columna a la izquierda
    LD A, (IX) ; Guardamos el contenido de IX en A
    CP B ; Comparamos con B
    CALL Z, INC_CNT_IZQ ; Si son iguales, debemos incrementar el contador de consecutivos que hay hacia la 'izquierda' de la ficha
    JR Z, CONTAR_IZQUIERDA ; Si fueron iguales, podemos continuar contando más fichas en esta dirección

    POP HL
    CALL U_CALC_TABLERO_POS ; Volvemos al IX de la ficha que fue soltada en este turno
    LD DE, COLUMN_BOARD_SIZE ; Cargamos 7 en DE
CONTAR_DERECHA: ; Mismo concepto que CONTAR_IZQUIERDA, pero desplaza en columnas hacia la derecha en vez de la izquierda
    LD A, (JUGADOR_ACTUAL) 
    LD B, A 
    ADD IX, DE
    LD A, (IX)
    CP B 
    CALL Z, INC_CNT_DER
    JR Z, CONTAR_DERECHA
    CALL CONTAR_TOTALES ; Cuenta el total de consecutivos a la izquierda y derecha de la ficha soltada.
    RET

; COMPROBACION DE VICTORIA EN VERTICAL
LC_COMPROBAR_4_EN_RAYA_VERTICAL: ; Mismo concepto que comprobación en horizontal, pero puede hacer DEC IX e INC IX directamente
    PUSH HL
    LD IX, TABLERO_ACTUAL
    CALL U_CALC_TABLERO_POS
    LD C, 0   
CONTAR_ARRIBA:
    LD A, (JUGADOR_ACTUAL)
    LD B, A
    DEC IX
    LD A, (IX) 
    CP B
    CALL Z, INC_CNT_IZQ
    JR Z, CONTAR_ARRIBA

    POP HL
    CALL U_CALC_TABLERO_POS
CONTAR_ABAJO:
    LD A, (JUGADOR_ACTUAL)
    LD B, A
    INC IX
    LD A, (IX)
    CP B
    CALL Z, INC_CNT_DER
    JR Z, CONTAR_ABAJO
    CALL CONTAR_TOTALES
    RET

; COMPROBACION DE VICTORIA EN DIAGONALES
LC_COMPROBAR_4_EN_RAYA_DIAGONALES:
    LD IX, TABLERO_ACTUAL
    CALL U_CALC_TABLERO_POS
    LD C, 0   
    PUSH HL
CONTAR_UPPER_LEFT:
    ; DESPLAZAMIENTO DE IX
    LD A, (JUGADOR_ACTUAL)
    LD B, A
    DEC H: DEC L ; Movemos IX a la posición diagonal superior izquierda
    CALL U_CALC_TABLERO_POS
    LD A, (IX)
    CP B 
    CALL Z, INC_CNT_IZQ
    JR Z, CONTAR_UPPER_LEFT
    POP HL
    PUSH HL
CONTAR_LOWER_RIGHT:
    ; DESPLAZAMIENTO DE IX
    LD A, (JUGADOR_ACTUAL)
    LD B, A
    INC H: INC L ; Movemos IX a la posición diagonal inferior derecha
    CALL U_CALC_TABLERO_POS
    LD A, (IX)
    CP B
    CALL Z, INC_CNT_DER
    JR Z, CONTAR_LOWER_RIGHT
    POP HL
    CALL CONTAR_TOTALES ; Contamos totales en esa diagonal Superior Izquierda + Inferior Derecha
    RET NZ ; RET aquí si ya se consiguió que los totales superaran 3.
    PUSH HL 
CONTAR_UPPER_RIGHT: ; Mismo concepto que el conteo de la otra diagonal
    ; DESPLAZAMIENTO DE IX
    LD A, (JUGADOR_ACTUAL)
    LD B, A
    DEC H: INC L ; Movemos IX una fila arriba y una columna a la derecha
    CALL U_CALC_TABLERO_POS
    LD A, (IX)
    CP B 
    CALL Z, INC_CNT_DER
    JR Z, CONTAR_UPPER_RIGHT
    POP HL 
    PUSH HL
CONTAR_LOWER_LEFT:
    ; DESPLAZAMIENTO DE IX
    LD A, (JUGADOR_ACTUAL)
    LD B, A
    INC H: DEC L ; Movemos IX una fila abajo y una columna a la izquierda
    CALL U_CALC_TABLERO_POS
    LD A, (IX)
    CP B 
    CALL Z, INC_CNT_IZQ
    JR Z, CONTAR_LOWER_LEFT
    POP HL 
    CALL CONTAR_TOTALES
    RET

; Contar total de consecutivos a partir de un punto 
CONTAR_TOTALES:
    LD A, (LEFT_COUNTER) ; Guardamos el contador lateral 1
    LD C, A ; Lo guardamos en C
    LD A, (RIGHT_COUNTER) ; Guardamos el contador lateral 2 
    ADD A, C ; Le agregamos C - A = Left_Counter + Right_Counter
    INC A ; A = Left_Counter + Right_Counter + 1
    ; Ficha soltada + consecutivas a un lado + consecutivas al opuesto
    CP 4 ; Comparamos con 4
    JR NC, SALIDA_CONTAR_TOTALES ; Si fue 4 o más, el flag carry estará en 0 = NC
    LD A, 0 ; Guardar A = 0
    LD (LEFT_COUNTER), A ; Reiniciamos los contadores
    LD (RIGHT_COUNTER), A
SALIDA_CONTAR_TOTALES:
    OR A ; No modifica A pero activa flags según el caso
    RET ; RET CON EL VALOR DE GANADOR (A != 0) o NO

; Cuenta consecutivos a un lado de la ficha soltada
INC_CNT_IZQ:
    PUSH AF
    LD A, (LEFT_COUNTER)
    INC A ; Incrementa el contador por 1
    LD (LEFT_COUNTER), A ; Guarda el nuevo valor en la variable
    POP AF
    RET

; Cuenta consecutivos al lado opuesto de la rutina superior 
INC_CNT_DER:
    PUSH AF
    LD A, (RIGHT_COUNTER)
    INC A ; Incrementa el contador por 1
    LD (RIGHT_COUNTER), A ; Guarda el nuevo valor en la variable
    POP AF
    RET


LC_SLOT_POINTER:
; SLOT_POINTER - Calcula dirección de videoram a partir de fila/columna del tablero, no de la pantalla
; H = fila del tablero, L = columna del tablero, HL = dirección de videoram
    ; PREREQUISITO: HABER SELECCIONADO UNA FILA Y UNA COLUMNA (H Y L) SOBRE LA QUE SE QUIERE OBTENER UNA DIRECCIÓN VIDEORAM
    ; H = FILA
    ; L = COLUMNA
    ; HL = DIRECCIÓN DE LA VIDEORAM

    PUSH AF
    LD A, L
    ADD L: ADD L: ADD 5
    LD L, A
    LD A, H ; 0 0 0 H4 H3 H2 H1 H0
    ADD H: ADD H: ADD 2
    LD H, A
    SLA A: SLA A: SLA A: SLA A: SLA A ; H2 H1 H0 0 0 0 0 0
    OR L ; H2 H1 H0 L4 L3 L2 L1 L0
    LD L, A
    LD A, H ; 0 0 0 H4 H3 H2 H1 H0
    SRA A: SRA A: SRA A; 0 0 0 0 0 0 H4 H3 
    OR $58 ; 0 1 0 1 1 0 H4 H3
    LD H, A
    ; HL = 0 1 0 1 1 0 H4 H3 H2 H1 H0 L4 L3 L2 L1 L0
    POP AF
    RET 

LC_VALIDPLAY:
    ; Comprueba si la jugada solicitada por el jugador es válida:
    ;   - Recibe en HL el valor actual de la ficha, no el valor al que se podría desplazar, será 0,L
    ;   - Para Q/W y O/P (izquierda/derecha) se comprueba que la celda objetivo no esté ocupada
    ;   - Para F se considerará válida si la columna no está ocupada en la posición del cursor
    ;   - Para ENTER se considerará válida si la columna actual no está llena
    LD A, D
    CP 'Q': JR Z, VALIDLEFT
    CP 'I': JR Z, VALIDLEFT
    CP 'W': JR Z, VALIDRIGHT
    CP 'O': JR Z, VALIDRIGHT
    CP 'E': JR Z, VALIDENTER
    CP 'P': JR Z, VALIDENTER
    CP 'F': JR Z, VALID ; F = Fin de la partida, siempre es válido

; Comprueba si fue una pulsación váida para mover la ficha a la izquierda
VALIDLEFT:
    PUSH HL
    LD HL, $00
    CALL LC_SLOT_POINTER
    LD A, (HL)
    POP HL
    CP BLINK ; si el atributo de color en HL es menor que blink (que lo será si no está sobre la posición más izquierda del tablero)
    JR C, VALID ; se hará una activación del flag C, por lo que será válida la pulsación
    JR NONVALID

; Comprueba si fue una pulsación válida para mover la ficha a la derecha
VALIDRIGHT:
    PUSH HL
    LD HL, $06 ; mismo concepto que validleft, pero la comparación se hace con el contenido de la fila 0, columna 6 en vez de la 0,0
    CALL LC_SLOT_POINTER
    LD A, (HL)
    POP HL
    CP BLINK
    JR C, VALID
    JR NONVALID
VALIDENTER: ; mismo concepto que validleft y right, pero la comparación se hace con la ficha inmediatamente inferior
    PUSH DE: PUSH HL
    CALL U_CALC_TABLERO_POS
    LD A, (IX)
    POP HL: POP DE
    CP 0: JR Z, VALID ; si aquí no saltó a valid, lee directamente la siguiente instrucción,
                      ; que serán las correspondientes a NONVALID 

NONVALID:
    LD A, 1
    RET
VALID:
    LD A, 2
    RET


