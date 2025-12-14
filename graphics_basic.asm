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
NOMBRE_GANADOR: DB "           ", 0 ; 11 caracteres + 1 byte para el 0 = 12 bytes
                DB "   ROJO    ", 0
                DB "  MAGENTA  ", 0
                DB "   VERDE   ", 0
                DB "  CELESTE  ", 0
                DB " AMARILLO  ", 0
                DB "  BLANCO   ", 0
CHAR_CARACTER: DB 0, 0                               ; buffer de 1 byte para el caracter pulsado

; PANTALLA DE INICIO
PANTALLA_BIENVENIDA: INCBIN "connect4screen.SCR" ; Pantalla inicial (portada) del juego
PANTALLA_JUEGO: INCBIN "connect4gameScreen.scr" ; Pantalla del tablero en la partida

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

; 
GB_PRUEBA: ; Pinta en pantalla el atributo de parpadeo en la posición indicada
    LD B, 21
    LD C, 30
    LD HL, $5800 + 21*NUM_COLS + 30  ; dirección de la celda (fila*NUM_COLS + col) en buffer de pantalla
    LD (HL), A                        ; escribe el atributo (parpadeo) directamente en VRAM
    POP AF: POP BC: POP HL: POP DE    ; restaura registros y sale

    RET
; GB_BLINKER_JUGAR BUENO
GB_BLINKER_JUGAR:
    LD B, 21
    LD C, 30
    LD HL, $5800 + 21*NUM_COLS + 30  ; dirección de la celda (fila*NUM_COLS + col) en buffer de pantalla
    LD (HL), A 
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

; GB_FIN_NEXT
; Imprime la pantalla y mensajes de fin de la partida, incluyendo el ganador de la partida
; y si se desea jugar nuevamente o no
GB_FIN_NEXT:
    PUSH DE: PUSH HL: PUSH BC: PUSH AF
    CALL PRINT_GANADOR
    POP AF: POP BC: POP HL: POP DE
    RET 

; GB_EMPATE
; Imprime el mensaje informando que la partida ha finalizado en un empate, ya que el tablero
; se llenó sin que ningún jugador consiguiera 4 en raya
GB_EMPATE:
    PUSH DE: PUSH HL: PUSH BC: PUSH AF
    CALL PTLLA_NEGRA
    LD B, 11
    LD C, 8
    LD A, 8*COLOR_TEXTO_ROJO
    LD IX, STRING_FILA_VACIA_E
    CALL PRINTAT 
    LD B, 13
    LD C, 8
    LD A, 8*COLOR_TEXTO_ROJO
    LD IX, STRING_FILA_VACIA_E
    CALL PRINTAT 
    LD B, 12
    LD C, 8
    LD A, 8*COLOR_TEXTO_ROJO
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

; Impresion del mensaje ofreciendo jugar otra partida
PRINT_OTRA:
    LD B, 21
    LD C, 0
    LD A, 8*COLOR_TEXTO_ROJO
    LD IX, STRING_OTRA
    CALL PRINTAT
    LD A, BLINK + 8*COLOR_TEXTO_ROJO
    CALL GB_BLINKER_JUGAR
    RET

; GB_PTLLA_INICIO_DE_JUEGO
; Imprime la pantalla inicial del tablero con la cuadrícula de 6x7 y los círculos (de momento no visibles)
; por encima del tablero. 
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

; Rutina que imprime los controles para cada jugador, en su respectivo color
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

; Impresion del ganador, incluye mensaje general de victoria + el nombre del jugador ganador en su color.
PRINT_GANADOR:
    CALL GB_PRINT_FONDO_GANADOR
    LD B, 11
    LD C, 4
    LD A, COLOR_BLANCO    ; atributo/color para el texto de adiós
    LD IX, MENSAJE_VICTORIA
    CALL PRINTAT
    LD B, 12    ; Fila donde saldra el nombre
    LD C, 10    ; Columna 
    PUSH BC ; Guardamos coordenadas
    LD IX, NOMBRE_GANADOR
    LD A, (GANADOR): PUSH AF    ; Guardamos color
    LD B, A: DEC B
    JR Z, IMPRIMIR_GANADOR
    LD DE, 12   ; Longitud 11 letras + 1 cero
CONSEGUIR_GANADOR:
    ADD IX, DE 
    DJNZ CONSEGUIR_GANADOR
IMPRIMIR_GANADOR:
    POP AF: POP BC  ; Recuperamos color y coordenadas
    CALL PRINTAT
    CALL PRINT_OTRA ; Imprime el mensaje ofreciendo jugar otra partida
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

; PARA LA PANTALLA DE GANADOR, AL DARLE A LA F
GB_PRINT_FONDO_GANADOR:
    PUSH HL : PUSH BC : PUSH AF
    LD HL, $5800
    LD B, COLOR_BLANCO_FONDO_GANADOR
BUCLE_PTLLA:
    LD (HL), B
    INC HL
    LD A, H
    CP $5B
    JR NZ, BUCLE_PTLLA
    POP AF : POP BC : POP HL
    RET