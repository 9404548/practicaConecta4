GB_BIENVENIDA:
    INCLUDE "S_N.asm"
BIENVENIDA:
    DB "Bienvenido al Conecta 4",0
JUGAR:
    DB "Quieres jugar?", 0
CARACTER: 
    DB 0,0
COLOR EQU 1 
    INCLUDE "printat.asm"

INICIO:
    ;CALL S_N
    LD A,2 + 128            ; Rojo y parpadeante
    LD B,0                  ; Fila 0
    LD C,3                  ; Columna 3
    LD IX,BIENVENIDA        ; Sale arriba el Bienvenido al conecta 4 en rojo y parpadeante
    CALL PRINTAT
    LD A,COLOR
    LD B,10                 ; Posicion del Quieres Jugar?
    LD C,1
    LD IX,JUGAR
    CALL PRINTAT
    ADD A,128+8             ; Color en parpadeante
    LD ($5800+10*32+16),A
    CALL S_N
    LD (CARACTER),A         ; Pone el caracter parpadeante
    LD A,COLOR
    LD B,10
    LD C,18
    LD IX,CARACTER
    CALL PRINTAT
    HALT
GB_ADIOS:
GB_FIN_NEXT:
GB_PTLLA_INICIO_DE_JUEGO: