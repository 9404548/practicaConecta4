; STRINGS PARA IMPRESION

STRING_FILA_VACIA_B: DB "                        ", 0    ; fila vacía (ancho para portada)
STRING_BIENVENIDA: DB " Bienvenido a Conecta 4 ", 0    ; texto principal de bienvenida
STRING_JUGAR: DB " Quieres jugar? S/N:   ", 0          ; pregunta para iniciar partida
STRING_FILA_VACIA_J: DB "                       ", 0   ; otra fila vacía para espaciado
STRING_FILA_VACIA_A: DB "            ", 0           ; fila vacía (alineación en pantalla)
STRING_ADIOS: DB "  ADIOS!!!! ", 0                 ; mensaje de despedida
STRING_EMPATE: DB " HAN EMPATADO ", 0     ; mensaje cuando termina la partida
STRING_FILA_VACIA_E: DB "              ", 0
STRING_OTRA: DB " QUIEREN JUGAR OTRA VEZ? S/N:   ", 0 ; preguntar por otra partida
STRING_CONTROLES_J1: DB "Q=IZQ, W=DER", 0
STRING_CONTROLES_J2: DB "I=IZQ, O=DER", 0
STRING_BAJAR: DB "BAJAR= / ", 0
STRING_BJ1: DB "E", 0
STRING_BJ2: DB "P", 0
MENSAJE_VICTORIA: DB " HA GANADO EL JUGADOR ", 0
NOMBRE_GANADOR: DB "           "
                DB "   ROJO    "
                DB "  MAGENTA  "
                DB "   VERDE   "
                DB "  CELESTE  "
                DB " AMARILLO  "
                DB "  BLANCO   "
CHAR_CARACTER: DB 0, 0                               ; buffer de 1 byte para el caracter pulsado

; PANTALLA DE INICIO
PANTALLA_BIENVENIDA: INCBIN "connect4screen.SCR"
PANTALLA_JUEGO: INCBIN "connect4gameScreen.scr"

GB_BIENVENIDA:
    ; Guardamos registros usados antes de manipular la pantalla
    PUSH DE: PUSH HL: PUSH BC: PUSH AF

    ; Copia la imagen BIN a la VRAM/direccion de pantalla
    LD DE, $4000                 ; dirección destino en memoria de pantalla (ejemplo)
    LD HL, PANTALLA_BIENVENIDA  ; dirección fuente (bin incluido)
    LD BC, $5B00 - $4000        ; longitud en bytes a copiar
BIENVENIDA_BUCLE:
    LDIR ; copia BC bytes desde (HL) a (DE) incrementando HL/DE

; PRINT_BIENVENIDA: imprime texto y mensajes sobre la portada cargada
; Convención usada por PRINTAT (por contrato):
;   B = fila, C = columna, IX = puntero a cadena, A = atributo/color (opcional)
PRINT_BIENVENIDA: ; IMPRIME EL MENSAJE DE BIENVENIDA
    LD B, 1
    LD C, 4
    LD IX, STRING_FILA_VACIA_B
    CALL PRINTAT
    LD B, 3
    LD IX, STRING_FILA_VACIA_B
    CALL PRINTAT
    LD B, 2
    LD A, COLOR_TEXTO_ROJO         ; atributo de color para la línea central
    LD IX, STRING_BIENVENIDA
    CALL PRINTAT

    ; Espaciado y pregunta para jugar
    LD B, 20
    LD C, 9
    LD IX, STRING_FILA_VACIA_J
    CALL PRINTAT
    LD B, 22
    LD IX, STRING_FILA_VACIA_J
    CALL PRINTAT
    LD B, 21
    LD A, COLOR_TEXTO_AMARILLO     ; color para la pregunta
    LD IX, STRING_JUGAR ; IMPRIME EL MENSAJE PREGUNTANDO SI SE QUIERE JUGAR
    CALL PRINTAT
    ; Preparamos el atributo para el blinker (parpadeo)
    LD A, BLINK + 8*COLOR_TEXTO_AMARILLO ; BLINK combinado con un valor de color

GB_BLINKER_JUGAR: ; Pinta en pantalla el atributo de parpadeo en la posición indicada
    LD B, 21
    LD C, 30
    LD HL, $5800 + 21*NUM_COLS + 30  ; dirección de la celda (fila*NUM_COLS + col) en buffer de pantalla
    LD (HL), A                        ; escribe el atributo (parpadeo) directamente en VRAM
    POP AF: POP BC: POP HL: POP DE    ; restaura registros y sale

    RET

GB_PRINT_CHAR_SON: ; Imprime el caracter que escribió el usuario en la misma posición del blinker
    LD B, 21
    LD C, 30
    LD IX, CHAR_CARACTER
    CALL PRINTAT

    RET

GB_ADIOS: ; Muestra la pantalla de despedida 'ADIOS' (uso similar a bienvenida)
    CALL PTLLA_NEGRA    ; limpia la pantalla antes de escribir
PRINT_ADIOS:
    LD B, 10
    LD C, 10
    LD A, 8*COLOR_TEXTO_ROJO    ; atributo/color para el texto de adiós
    LD IX, STRING_FILA_VACIA_A
    CALL PRINTAT
    LD B, 12
    LD A, 8*COLOR_TEXTO_ROJO
    LD IX, STRING_FILA_VACIA_A
    CALL PRINTAT
    LD B, 11
    LD A, 8*COLOR_TEXTO_ROJO
    LD IX, STRING_ADIOS
    CALL PRINTAT

    RET

GB_FIN_NEXT:
    PUSH DE: PUSH HL: PUSH BC: PUSH AF
    CALL PRINT_GANADOR
    POP AF: POP BC: POP HL: POP DE
    RET 

GB_EMPATE:
    PUSH DE: PUSH HL: PUSH BC: PUSH AF
    LD IX, STRING_FILA_VACIA_E
    LD B, 11
    LD C, 8
    LD A, COLOR_TEXTO_ROJO
    CALL PRINTAT 
    LD B, 13
    CALL PRINTAT 
    LD B, 12
    LD IX, STRING_EMPATE
    CALL PRINTAT 
    POP AF: POP BC: POP HL: POP DE
    RET

PRINT_FIN:
    LD B, 15
    LD C, 3
    LD A, 8*COLOR_TEXTO_ROJO
    LD IX, STRING_EMPATE
    CALL PRINTAT
PRINT_OTRA:
    LD B, 21
    LD C, 0
    LD A, 8*COLOR_TEXTO_ROJO
    LD IX, STRING_OTRA
    CALL PRINTAT
    LD A, BLINK + 8*COLOR_TEXTO_ROJO
    CALL GB_BLINKER_JUGAR
    RET

GB_PTLLA_INICIO_DE_JUEGO:
    ; Inicializa la pantalla del juego (limpia y carga la plantilla de juego)
    CALL PTLLA_NEGRA
    ; Guardamos registros usados antes de manipular la pantalla
    PUSH DE: PUSH HL: PUSH BC: PUSH AF

    ; Copia la imagen BIN a la VRAM/direccion de pantalla
    LD DE, $4000                 ; dirección destino en memoria de pantalla (ejemplo)
    LD HL, PANTALLA_JUEGO  ; dirección fuente (bin incluido)
    LD BC, $5B00 - $4000        ; longitud en bytes a copiar
PTLLA_JUEGO_BUCLE:
    LDIR ; copia BC bytes desde (HL) a (DE) incrementando HL/DE

    POP AF: POP BC: POP HL: POP DE

PRINT_CONTROLES:
    LD B, 0
    LD C, 1
    LD A, COLOR_JUGADOR1    ; atributo/color para el texto de adiós
    LD IX, STRING_CONTROLES_J1
    CALL PRINTAT
    LD C, 20
    LD A, COLOR_JUGADOR2
    LD IX, STRING_CONTROLES_J2
    CALL PRINTAT
    LD B, 23
    LD C, 10
    LD A, COLOR_BLANCO
    LD IX, STRING_BAJAR
    CALL PRINTAT
    LD B, 23
    LD C, 16
    LD A, COLOR_JUGADOR1
    LD IX, STRING_BJ1
    CALL PRINTAT
    LD B, 23
    LD C, 18
    LD A, COLOR_JUGADOR2
    LD IX, STRING_BJ2
    CALL PRINTAT
    RET

PRINT_GANADOR:
    LD B, 11
    LD C, 4
    LD A, COLOR_BLANCO    ; atributo/color para el texto de adiós
    LD IX, MENSAJE_VICTORIA
    CALL PRINTAT
    LD B, 12
    LD C, 10
    PUSH BC
    LD IX, NOMBRE_GANADOR
    LD A, (GANADOR): PUSH AF
    LD B, A: DEC B
    LD DE, 11
CONSEGUIR_GANADOR:
    ADD IX, DE 
    DJNZ CONSEGUIR_GANADOR
    POP AF: POP BC
    CALL PRINTAT
    CALL PRINT_OTRA
    RET

PTLLA_NEGRA:
    ; Llena la pantalla con ceros (pantalla en negro)
    PUSH BC: PUSH DE: PUSH HL: PUSH AF

    LD   HL,$5800
    LD   DE,$5801
    LD   (HL),0
    LD   BC,768-1
    LDIR    ; copia 768 bytes-1 para limpiar buffer de pantalla

    POP AF: POP HL: POP DE: POP BC
    RET