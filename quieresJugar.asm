    INCLUDE "s_n.ASM"
    INCLUDE "printat.asm"

FILA_VACIA_B: DB "                        ", 0
BIENVENIDA: DB " Bienvenido a Conecta 4 ", 0
JUGAR: DB " Quieres jugar?   ", 0
FILA_VACIA_J: DB "                  ", 0
CARACTER: DB 0, 0
COLOR_AMARILLO EQU 6

MENSAJE_BIENVENIDA:
    LD B, 1
    LD C, 4
    LD IX, FILA_VACIA_B
    CALL PRINTAT
    LD B, 3
    LD IX, FILA_VACIA_B
    CALL PRINTAT
    LD B, 2
    LD A, 2
    LD IX, BIENVENIDA
    CALL PRINTAT
    
    LD B, 20
    LD C, 1
    LD IX, FILA_VACIA_J
    CALL PRINTAT
    LD B, 22
    LD IX, FILA_VACIA_J
    CALL PRINTAT
    LD B, 21
    LD A, COLOR_AMARILLO
    LD IX, JUGAR
    CALL PRINTAT

    LD A, 128 + 8*COLOR_AMARILLO
    LD($5800 + 21*32 + 17), A
    CALL S_N
    LD (CARACTER), A
    PUSH AF
    LD A, COLOR_AMARILLO
    LD B, 21
    LD C, 17
    LD IX, CARACTER
    CALL PRINTAT
    POP AF
    
    RET
