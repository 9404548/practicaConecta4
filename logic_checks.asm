; Lógica de comprobaciones del juego (Conecta 4)
; Constantes y configuración:
ULTIMA_FICHA_COLUMNA EQU $C001 ; Byte (0-6) con la columna de la última ficha jugada
ULTIMA_FICHA_FILA EQU $C002    ; Byte (0-5) con la fila de la última ficha jugada
TABLERO_ANCHO EQU 7
TABLERO_ALTO EQU 6
ESTADO_TABLERO EQU $D000      ; dirección base en memoria donde se almacena el tablero (fila-major)
; Nota: se espera que otras rutinas escriban la columna/fila en las direcciones ULTIMA_FICHA_* antes de llamar

; LC_COMPROBAR_FIN
;  - Rutina principal que invoca las comprobaciones de victoria en las cuatro direcciones.
;  - Guarda registros y llama a subrutinas: vertical, horizontal, diagonal1, diagonal2.
;  - Si alguna detecta victoria devuelve con CARRY=1 (JR C, FIN_DE_JUEGO_DETECTADO)
LC_COMPROBAR_FIN:
    PUSH AF : PUSH BC : PUSH DE : PUSH IX 
    ; VERIFICACIONES (cada llamada debe preservar o restaurar los registros que use)
    CALL LC_CHECK_VERTICAL
    JR C, FIN_DE_JUEGO_DETECTADO

    CALL LC_CHECK_HORIZONTAL
    JR C, FIN_DE_JUEGO_DETECTADO

    CALL LC_CHECK_DIAGONAL1
    JR C, FIN_DE_JUEGO_DETECTADO

    CALL LC_CHECK_DIAGONAL2
    JR C, FIN_DE_JUEGO_DETECTADO

    ; COMPROBAR SI HA GANADO UN JUGADOR

    ; COMPROBAR SI HAY EMPATE
LC_COMPROBAR_4ENLINEA:
    PUSH AF : PUSH BC : PUSH DE : PUSH IX 
    LD C,4        ; numero de iteraciones (comprobar 4 fichas)
    LD E,0        ; contador de fichas seguidas encontradas
COMPROBAR_BUCLE:
    LD D, (HL)    ; carga en D el valor/color de la casilla apuntada por HL
    CP D          ; compara A con D (se asume que A es el color a buscar o que D contiene el jugador actual)
    JR NZ, NO_COINCIDE

    INC E         ; si coincide, incrementa el contador de seguidas
    LD D,4        ; numero objetivo de fichas para ganar (4)
    CP E          ; comparar contador con 4
    JR Z, HAY_VICTORIA
    JR COINCIDE_SIGUIENTE

COINCIDE_SIGUIENTE:
    PUSH BC
    LD B,0        ; prepara salto/offset en BC (si corresponde al modo de avance)
    LD C,B
    ADD HL        ; avance de HL por el salto indicado en BC (implementación depende del llamado)
    POP BC

    DJNZ, COMPROBAR_BUCLE   ; repetir C veces 

    AND A         ; limpiar carry si el bucle termina sin victoria
    JR FINALIZAR_CHECK

FINALIZAR_CHECK:
    POP IX: POP DE: POP HL
    RET
HAY_VICTORIA:
    SCF            ; activa carry para indicar victoria al llamador
NO_COINCIDE:
    LD E,0         ; reinicia contador de fichas seguidas


; SE COMPRUEBAN LAS POSICIONES DE LAS FICHAS: VERTICAL, HORIZONTAL, DIAG IZQ y DIAG DER

LC_CHECK_VERTICAL:
;  - Comprueba hacia abajo desde la última ficha (solo dirección vertical descendente)
;  - Flujo:
;    * Cargar fila y columna última
;    * Calcular offset = fila * TABLERO_ANCHO + columna
;    * Ajustar HL a la dirección dentro de ESTADO_TABLERO
;    * Preparar A con el color a buscar y B con el salto vertical (TABLERO_ANCHO)
;    * Llamar a LC_COMPROBAR_4ENLINEA para comprobar 4 en línea
    LD A, (ULTIMA_FICHA_FILA)
    LD B, TABLERO_ANCHO
    CALL MULTIPLY_A_B ; HL = FILA * ANCHO (resultado en DE)
    LD A, (ULTIMA_FICHA_COLUMNA)
    ADD L   ; HL = FILA*ANCHO + COLUMna (forma de sumar columna al offset en HL)
    LD HL, ESTADO_TABLERO
    ADD HL, DE  ; HL = direccion de la ultima ficha en memoria del tablero

    LD A, ; AQUI IRIA EL JUGADOR ACTUAL (valor/color buscado)
    LD B, TABLERO_ANCHO

    CALL LC_COMPROBAR_4ENLINEA

    POP HL: POP DE: POP BC: POP AF
    RET

; LC_CHECK_HORIZONTAL
;  - Comprueba la fila de la última ficha en busca de 4 en línea horizontalmente
;  - Ajusta HL al inicio de la fila y itera incrementando HL por 1 byte (salto horizontal)
LC_CHECK_HORIZONTAL:
    PUSH AF: PUSH BC: PUSH DE: PUSH HL
    ; calcular posicion inicial de la fila
    LD A, (ULTIMA_FICHA_FILA)
    LD B, TABLERO_ANCHO
    CALL MULTIPLY_A_B
    LD HL, ESTADO_TABLERO
    ADD HL, DE
    LD C,4  ; bucle de 4 repeticiones (se prueban 4 ventanas)

HORIZONTAL_BUCLE:
    PUSH HL
    LD A, ; AQUI LA DIRECCION DE MEMORIA DEL JUGADOR ACTUAL (EL COLOR A BUSCAR)
    LD B,1  ; salto horizontal = 1 byte (siguiente columna)
    CALL LC_COMPROBAR_4ENLINEA

    POP HL
    JR C, HORIZONTAL_VICTORIA   ; si LC_COMPROBAR_4ENLINEA puso carry, es victoria

    INC HL  ; pasar a la siguiente columna
    DJNZ HORIZONTAL_BUCLE

HORIZONTAL_SIN_VICTORIA:
    AND A   ; limpiar flags (C=0)
    POP HL: POP DE: POP BC: POP AF
    RET
HORIZONTAL_VICTORIA:
    SCF
    POP HL: POP DE: POP BC: POP AF
    RET
MULTIPLY_A_B:
    ; Rutina ingenua para multiplicar A * B y dejar el resultado en DE (usando HL como acumulador)
    PUSH AF : PUSH BC
    LD HL, 0
    LD C,A 
    LD A,0  ; contador
MULT_BUCLE:
    ADD HL,BC
    INC A
    CP C 
    JR NZ, MULT_BUCLE
    POP BC: POP AF
    RET
FIN_DE_JUEGO_DETECTADO:
    ; Salida cuando alguna comprobación detectó fin de juego (victoria)
    LD A,0
    POP AF : POP BC : POP DE : POP IX 
    RET

LC_VALIDPLAY:
    ; Comprueba si la jugada solicitada por el jugador es válida:
    ;   - Para Q/W (izquierda/derecha) se comprueba que la celda objetivo no esté ocupada
    ;   - Para F se considerará válida si la columna no está ocupada en la posición del cursor
    LD A, D
    CP 'Q'
    JR Z, VALIDLEFT
    CP 'W'
    JR Z, VALIDRIGHT
    ; AQUI AGREGAREMOS DESPUES LA COMPROBACION PARA JUGADA VALIDA DE ENTER
    CP 'F'
    JR Z, VALID
VALIDLEFT:
    PUSH HL
    LD HL, $5845
    LD A, (HL)
    POP HL
    CP BLINK + PLAYER1
    JR Z, NONVALID
    CP BLINK + PLAYER2
    JR Z, NONVALID
    JR VALID
VALIDRIGHT:
    PUSH HL
    LD HL, $5857
    LD A, (HL)
    POP HL
    CP BLINK + PLAYER1
    JR Z, NONVALID
    CP BLINK + PLAYER2
    JR Z, NONVALID
    JR VALID
NONVALID:
    LD A, 1
    RET
VALID:
    LD A, 2
    RET
    
